mod custom_resource;
mod server;

use std::{
    collections::HashMap,
    pin::pin,
    sync::{Arc, Mutex},
    time::{Duration, Instant, SystemTime, UNIX_EPOCH},
};

use custom_resource::{SecondCronJob, SecondCronJobSpec};
use futures::TryStreamExt;
use k8s_openapi::{
    api::batch::v1::Job,
    apiextensions_apiserver::pkg::apis::apiextensions::v1::CustomResourceDefinition,
};
use kube::{
    api::{DeleteParams, PostParams},
    runtime::{
        watcher::{watcher, Config},
        WatchStreamExt,
    },
    Api, Client, CustomResourceExt, ResourceExt,
};
use tokio::time::sleep;

async fn handle_custom_resource_defintion(client: Client) -> anyhow::Result<()> {
    let all_crd_list: Api<CustomResourceDefinition> = Api::all(client);

    // 이미 CRD가 있다면 제거
    let delete_params: kube::api::DeleteParams = DeleteParams::default();
    let _ = all_crd_list
        .delete("secondcronjobs.myyrakle.com", &delete_params)
        .await
        .map(|res| {
            res.map_left(|o| {
                println!(
                    "Deleting {}: ({:?})",
                    o.name_any(),
                    o.status.unwrap().conditions.unwrap().last()
                );
            })
            .map_right(|s| {
                println!("secondcronjobs.myyrakle.com 삭제완료: ({:?})", s);
            })
        });
    sleep(Duration::from_secs(3)).await;

    // CRD 생성
    let new_crd = SecondCronJob::crd();
    let create_params = PostParams::default();

    match all_crd_list.create(&create_params, &new_crd).await {
        Ok(o) => {
            println!("Created {} ({:?})", o.name_any(), o.status.unwrap());
        }
        Err(kube::Error::Api(ae)) => assert_eq!(ae.code, 409), // 삭제 건너뛰기
        Err(e) => return Err(e.into()),                        // any other case is probably bad
    }
    // 뜰때까지 대기
    sleep(Duration::from_secs(1)).await;

    Ok(())
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let client = kube::Client::try_default().await?;

    server::run_server();

    handle_custom_resource_defintion(client.clone()).await?;

    let second_cronjobs: Api<SecondCronJob> = Api::default_namespaced(client.clone());

    let _resource_map = Arc::new(Mutex::new(HashMap::<String, SecondCronJobSpec>::new()));

    let resource_map = _resource_map.clone();
    // 스케줄러 - 1초 주기로 동작하며 Job 리소스를 생성
    tokio::spawn(async move {
        println!("@ Start Job Scheduler");

        let client = kube::Client::try_default().await.unwrap();
        let jobs: Api<Job> = Api::default_namespaced(client.clone());
        let mut last_run_map = HashMap::<String, Instant>::new();

        loop {
            let resource_list = {
                let locker = resource_map.lock().unwrap();

                locker
                    .iter()
                    .map(|e| (e.0.clone(), e.1.clone()))
                    .collect::<Vec<(String, SecondCronJobSpec)>>()
            };

            let now = SystemTime::now();
            let since_the_epoch = now.duration_since(UNIX_EPOCH).expect("Time went backwards");
            let utc = since_the_epoch.as_secs();

            for (name, spec) in resource_list {
                let interval = spec.interval_seconds;

                match last_run_map.get(&name) {
                    Some(last_run) if last_run.elapsed() < Duration::from_secs(interval as u64) => {
                        continue
                    }
                    _ => {}
                }

                let job: Job = serde_json::from_value(serde_json::json!({
                    "apiVersion": "batch/v1",
                    "kind": "Job",
                    "metadata": {
                        "name": format!("{}-job-{}", name, utc),
                        "label": {
                            "app": format!("{}-job", name),
                            "version": "1"
                        }
                    },
                    "spec": {
                        "backoffLimit": 3,
                        "template": {
                            "spec": {
                                "containers": [
                                    {
                                        "name": format!("{}-job", name),
                                        "image": spec.image
                                    }
                                ],
                                "restartPolicy": "Never"
                            }
                        }
                    }
                }))
                .unwrap();

                let create_params = PostParams::default();

                match jobs.create(&create_params, &job).await {
                    Ok(o) => {
                        println!("Created {} ({:?})", o.name_any(), o.status.unwrap());
                    }
                    Err(e) => {
                        println!("Error: {}", e);
                    }
                }

                last_run_map.insert(name, Instant::now());
            }

            tokio::time::sleep(Duration::from_secs(1)).await;
        }
    });

    let resource_map = _resource_map.clone();

    // 삭제된 리소스 감지 - 10초 주기로 동작
    let _client = client.clone();
    tokio::spawn(async move {
        println!("@ Start Resource Deletion Watcher");
        let client = _client.clone();
        loop {
            let names = resource_map
                .lock()
                .unwrap()
                .keys()
                .cloned()
                .collect::<Vec<String>>();

            let second_cronjobs: Api<SecondCronJob> = Api::default_namespaced(client.clone());

            for name in names {
                if let Err(_) = second_cronjobs.get(&name).await {
                    println!("Resource {} is deleted", name);

                    resource_map.lock().unwrap().remove(&name);
                }
            }

            tokio::time::sleep(Duration::from_secs(10)).await;
        }
    });

    let resource_map = _resource_map.clone();

    // 기존/신규 생성 리소스 감지
    let stream = watcher(second_cronjobs, Config::default()).applied_objects();

    let mut pinned_stream = pin!(stream);

    println!("@ Start watching custom resources");
    while let Some(event) = pinned_stream.try_next().await? {
        let resource_name = event.name_any();

        resource_map
            .lock()
            .unwrap()
            .insert(resource_name.clone(), event.spec);

        println!("Custom Resource: {}", resource_name);
    }

    return Ok(());
}

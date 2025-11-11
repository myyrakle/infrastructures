mod server;

use std::pin::pin;

use futures::TryStreamExt;
use k8s_openapi::api::core::v1::Pod;
use kube::{
    runtime::{
        watcher::{watcher, Config},
        WatchStreamExt,
    },
    Api, ResourceExt,
};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let client = kube::Client::try_default().await?;

    let pods: Api<Pod> = Api::default_namespaced(client);

    let stream = watcher(pods, Config::default()).applied_objects();
    let mut pinned_stream = pin!(stream);

    server::run_server();
    
    while let Some(event) = pinned_stream.try_next().await? {
        let pod_name = event.name_any();

        let status = event.status.map(|e| e.phase).flatten();

        println!("Pod: {} is in phase: {:?}", pod_name, status);
    }

    return Ok(());
}

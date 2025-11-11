use kube_derive::CustomResource;
use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

#[derive(CustomResource, Clone, Debug, Deserialize, Serialize, JsonSchema)]
#[kube(
    group = "myyrakle.com",
    version = "v1",
    kind = "SecondCronJob",
    namespaced
)]
pub struct SecondCronJobSpec {
    pub name: String,
    pub image: String,
}

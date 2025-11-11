use axum::{
    response::{Html, IntoResponse},
    routing::get,
    Router,
};
use lambda_web::{is_running_on_lambda, run_hyper_on_lambda, LambdaError};
use std::net::SocketAddr;

async fn index() -> Html<&'static str> {
    Html("<h1>Hello, World!</h1>")
}

async fn health() -> impl IntoResponse {
    "OK".into_response()
}

#[tokio::main]
async fn main() -> Result<(), LambdaError> {
    dotenv::dotenv().ok();

    // build our application with a route
    let app = Router::new()
        .route("/", get(index))
        .route("/health", get(health));

    if is_running_on_lambda() {
        // Run app on AWS Lambda
        run_hyper_on_lambda(app).await?;
    } else {
        // Run app on local server
        let addr = SocketAddr::from(([127, 0, 0, 1], 8080));
        axum::Server::bind(&addr)
            .serve(app.into_make_service())
            .await?;
    }
    Ok(())
}

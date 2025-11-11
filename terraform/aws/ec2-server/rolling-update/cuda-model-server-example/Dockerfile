FROM nvidia/cuda:12.8.0-base-ubuntu22.04
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY . /server
WORKDIR /server

# Install curl, make
RUN apt-get update && apt install -y make curl gcc g++

# Install Dependencies
RUN uv sync 

# Serve 
EXPOSE 80
ENTRYPOINT ["uv", "run", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "80"]
# Use the CUDA base image
FROM nvidia/cuda:11.5.2-cudnn8-runtime-ubuntu20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gnupg2 \
    curl \
    tzdata \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set the timezone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Add the deadsnakes PPA to install Python 3.10
RUN add-apt-repository ppa:deadsnakes/ppa

# Update packages list again
RUN apt-get update

# Install Python 3.10
RUN apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.10
RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Manually install Python 3.10 development headers
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.10-dev \
    && rm -rf /var/lib/apt/lists/*

# Update alternatives to use Python 3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Set CUDA environment variables
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Set the working directory
WORKDIR /app

# Install CUDA Toolkit
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cuda-toolkit-11-5 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file and install dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# Copy the entire project directory
COPY . /app

# Change directory to the main project directory
WORKDIR /app/tortoise_tts_clone

# Install the Python package
RUN pip install .

# Expose the port that your FastAPI app will run on
EXPOSE 8002

# Change directory back to the main project directory
WORKDIR /app

# Command to run the FastAPI app using uvicorn
CMD ["uvicorn", "main:app", "--port", "8002", "--host", "0.0.0.0"]

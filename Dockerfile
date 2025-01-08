FROM kalilinux/kali-rolling

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    git \
    bluez \
    libpcap-dev \
    libev-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libnl-route-3-dev \
    cmake \
    libbluetooth-dev \
    python3 \
    python3-pip \
    python3-venv \
    make \
    nano

# Clone the apple_bleee repository
WORKDIR /app
RUN git clone https://github.com/sealldeveloper/apple_bleee.git
WORKDIR /app/apple_bleee

# Set up submodules
RUN git submodule update --init

# Clone and setup owl
RUN git clone https://github.com/seemoo-lab/owl.git
WORKDIR /app/apple_bleee/owl
RUN git submodule update --init
WORKDIR /app/apple_bleee/owl/googletest
# https://github.com/seemoo-lab/owl/pull/79
RUN git checkout 58d77fa8070e8cec2dc1ed015d66b454c8d78850

# Build the project
WORKDIR /app/apple_bleee/owl
RUN mkdir build && cd build && \
    cmake .. && \
    make && \
    make install

# Set up Python environment and install requirements
WORKDIR /app/apple_bleee
RUN python3 -m venv apple_bleee && \
    . ./apple_bleee/bin/activate && \
    pip install --upgrade pip setuptools && \
    pip install git+https://github.com/pybluez/pybluez.git && \
    pip install -r requirements.txt

# Start Bluetooth Service
RUN service bluetooth start

# Set the entrypoint to activate the virtual environment and drop into bash
ENTRYPOINT ["/bin/bash", "-c", "source ./apple_bleee/bin/activate && exec bash"]

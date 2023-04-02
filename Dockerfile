FROM nvcr.io/nvidia/l4t-ml:r32.5.0-py3

#Add new sudo user
ENV USERNAME kanrisha
RUN useradd -m $USERNAME
RUN echo "$USERNAME:$USERNAME" | chpasswd
RUN usermod --shell /bin/bash $USERNAME
RUN usermod -aG sudo $USERNAME
RUN mkdir -p /etc/sudoers.d
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME
RUN chmod 0440 /etc/sudoers.d/$USERNAME
# Replace 1000 with your user/group id
RUN usermod  --uid 1000 $USERNAME
RUN groupmod --gid 1000 $USERNAME

RUN apt update
RUN apt upgrade -y

# Install python
RUN apt install -y python-pip python3-pip
RUN python3 -m pip install --upgrade pip

# install net tools
RUN apt install -y iputils-ping net-tools
RUN apt install -y nano software-properties-common

# Install ROS-melodic
ARG ROS_PKG=ros_base
ENV ROS_DISTRO=melodic
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y git cmake build-essential  curl wget gnupg2 lsb-release ca-certificates
RUN rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update
RUN apt install -y ros-melodic-desktop-full
RUN apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools
RUN rosdep init

# Change USER
USER ${USERNAME}

# Create Catkin Work Space
RUN mkdir -p /home/${USERNAME}/catkin_ws/src
WORKDIR /home/${USERNAME}/catkin_ws
RUN echo "source /opt/ros/melodic/setup.bash" >> /home/${USERNAME}/.bashrc
RUN sh -c "cd /home/${USERNAME}/catkin_ws/ && catkin init"
RUN sh -c 'echo "source ~/catkin_ws/devel/setup.bash" >> /home/${USERNAME}/.bashrc'
RUN sh -c "cd /home/${USERNAME}/catkin_ws/src && rosdep update && rosdep install -i --from-paths ./"

# Create playground_pkg
WORKDIR /home/${USERNAME}/catkin_ws/src/
RUN sh -c "cd /home/${USERNAME}/catkin_ws/src && catkin create pkg playground_pkg --catkin-deps roscpp rospy std_msgs"
COPY --chown=${USERNAME}:${USERNAME} playground_pkg/ playground_pkg/
ARG ROS_IP=192.168.11.2
RUN echo "export ROS_IP=${ROS_IP}" >> /home/${USERNAME}/.bashrc
RUN echo "echo 'ROS_IP = ${ROS_IP}'" >> /home/${USERNAME}/.bashrc

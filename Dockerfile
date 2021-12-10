FROM ros:melodic-perception
MAINTAINER Wang Binglu <soxpig@outlook.com>

ENV JOBS_NUM="4"

RUN	apt-get -y update && apt-get install -y \
	wget \
	libboost-all-dev \
	apt-utils \
	cmake git \
	libgoogle-glog-dev \
	libsuitesparse-dev \
	libgl1-mesa-dev \
	libglew-dev \
	libxkbcommon-x11-dev \
	ros-${ROS_DISTRO}-tf-conversions \
	ros-${ROS_DISTRO}-rviz && \
	rm -rf /var/lib/apt/lists/*

RUN	echo "deb http://package.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list
RUN	wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
RUN	apt-get -y update && apt-get -y install python-catkin-tools

COPY	Pangolin /root/Pangolin
COPY	eigen /root/eigen

RUN	cd /root/eigen && mkdir build && cd build && \
	cmake .. && make -j${JOBS_NUM} install && \
	cp -r /usr/local/include/eigen3/Eigen /usr/local/include && \
	cd /root/Pangolin && mkdir build && cd build && \
	cmake .. && make -j${JOBS_NUM} install && \
	rm -rf /root/*

RUN	cd /root && mkdir workspace && cd workspace && mkdir catkin_ws_ov && \
	cd catkin_ws_ov && mkdir src

COPY	openvins /root/workspace/catkin_ws_ov/src/openvins

RUN	cd /root/workspace/catkin_ws_ov && . /opt/ros/${ROS_DISTRO}/setup.sh && \
	exec bash && source /opt/ros/${ROS_DISTRO}/setup.bash && catkin build

ENV	DEBIAN_FRONTEND noninteractive

RUN	apt-get update -y && apt-get install -y \
	openssh-server xfce4 xfce4-goodies x11vnc sudo bash xvfb && \
	useradd -ms /bin/bash ubuntu && echo 'ubuntu:ubuntu' | chpasswd && \
	echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY 	x11vnc /etc/init.d/
COPY 	xvfb /etc/init.d/
COPY 	entry.sh /

RUN 	sudo chmod +x /entry.sh /etc/init.d/*

EXPOSE 	5902

ENTRYPOINT [ "/entry.sh" ]

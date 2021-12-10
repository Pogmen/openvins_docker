docker build -t pogman/openvins_v2 /home/pogman/docker-workspace/docker_openvins
docker run -itd -v /home/pogman/docker-workspace/docker_openvins:/root/Dataset:ro -p 5901:5901 pogman/openvins
docker run -itd -v /home/pogman/docker-workspace/docker_openvins:/root/Dataset:ro -p 5900:5900 pogman/openvins_v1
docker run -itd -v /home/pogman/docker-workspace/docker_openvins:/root/Dataset:ro -p 5902:5902 pogman/openvins_v2

docker cp /YOUR_PATH/LARVIO `docker ps | grep larvio_vnc_bionic | awk '{print $1}'`:/root/LARVIO

docker exec -it `docker ps | grep larvio_vnc_bionic | awk '{print $1}'` /bin/bash -c \
    '. /opt/ros/melodic/setup.bash && cd /root/LARVIO/ros_wrapper && catkin_make'

docker exec -itd `docker ps | grep larvio_vnc_bionic | awk '{print $1}'` /bin/bash -c \
    'cd /root/LARVIO/ros_wrapper && . devel/setup.bash && roslaunch larvio larvio_euroc.launch'

sleep 3

docker exec -it `docker ps | grep larvio_vnc_bionic | awk '{print $1}'` /bin/bash -c \
    '. /opt/ros/melodic/setup.bash && rosbag play /root/Dataset/bag/MH_01_easy.bag'

#!/bin/bash
cd fastik || ( echo "Cannot cd; exit" ; exit 3 )

FN=_gen_clam
R=5	# rounding digits

# Taken from http://wiki.ros.org/Industrial/Tutorials/Create_a_Fast_IK_Solution
# See also http://wiki.ros.org/Industrial/Tutorials/Create_a_Fast_IK_Solution/arm_navigation_plugin
# http://docs.ros.org/hydro/api/moveit_ikfast/html/doc/ikfast_tutorial.html

rosrun xacro xacro.py ../model/clam.xacro > $FN.urdf

rosrun collada_urdf urdf_to_collada $FN.urdf $FN.dae
./round_collada_numbers.py $FN.dae $FN.round$R.dae $R $R
#rosrun collada_urdf ./round_collada_numbers.py $FN.dae $FN.round$R.dae $R

openrave-robot.py $FN.dae --info links
openrave-robot.py $FN.dae --info joints

/usr/lib/python2.7/dist-packages/openravepy/_openravepy_/ikfast.py --robot=$FN.round$R.dae --iktype=transform6d --baselink=0 --eelink=8 --freeindex=2 --savefile=_gen_ikfast61.round$R.cpp -d 9

g++ -lstdc++ -llapack -o ik_test gen_ikfast61.round$R.cpp

# IKFast Moveit plugin
# The package lmt_clamarm_moveit_ikfast is generated by the GUI 
rosrun moveit_ikfast create_ikfast_moveit_plugin.py lmtclam arm lmt_clamarm_moveit_ikfast _gen_ikfast61.round$R.cpp

# Test of FastIK
openrave.py --database inversekinematics --robot=clam.robot.xml --iktests=1000
openrave.py --database inversekinematics --robot=clam.robot.xml --show
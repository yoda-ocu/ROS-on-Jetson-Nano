#!/usr/bin/env python
import rospy
from std_msgs.msg import String

def callback(msg):
    rospy.loginfo("Message '{}' recieved".format(msg.data))

def subscriber():
    rospy.init_node("subscriber")
    rospy.Subscriber("chatter", String, callback)
    rospy.spin()

if __name__ == "__main__":
    subscriber()
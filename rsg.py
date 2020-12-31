#!/usr/bin/python
# Random Selection Game
# Taken from https://sites.google.com/a/state.co.us/oit-plaza-dev/home/training/classes/piday

import random

entrants = ["Lillian", "William", "Nancy", "James", "Deb", "Brian"]

first_prize = random.randrange(0,len(entrants))

second_prize = random.randrange(0,len(entrants))
while second_prize == first_prize:
    second_prize = random.randrange(0,len(entrants))
third_prize = random.randrange(0,len(entrants))
while third_prize == first_prize or third_prize == second_prize:
    third_prize = random.randrange(0,len(entrants))
print("Selections are done and:")
print("1st Prize, a Raspberry Pi 3, goes to"), entrants[first_prize]
print("2nd Prize, a Raspberry Pi Zero, goes to"), entrants[second_prize]
print("3rd Prize, a gift card to Micro Center, goes to"), entrants[third_prize]

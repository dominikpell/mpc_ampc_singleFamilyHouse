# -*- coding: utf-8 -*-
"""
Created on Wed Mar  6 14:49:16 2019

@author: aku

PID controller
"""

import time

class PID():
    
    def __init__(self, Kp = 1, Ti = 100, Td = 0, lim_low = 0, lim_high = 100,
                 reverse_act = False, fixed_dt = 0):
        
        self.x_act = 0 # measurement
        self.e = 0  #control difference
        self.e_last = 0 #control difference of previous time step
        self.y = 0  #controller output
        self.i = 0  #integrator value
        
        self.Kp = Kp
        self.Ti = Ti
        self.Td = Td
        self.lim_low = lim_low   #low control limit
        self.lim_high = lim_high #high control limit
        self.reverse_act = reverse_act # control action
        self.fixed_dt = fixed_dt #if zero, system time between two runs is used
        self.t_old = time.time() #used to calculate dt if fixed_dt = 0
    
    
    ##### PID algorithm #############
    def run(self, x_act, x_set):
        self.x_act = x_act
        self.x_set = x_set
        
        #calculate delta t for integration if fixed_dt = 0
        if self.fixed_dt == 0:
            now = time.time()
            dt = now - self.t_old
            self.t_old = now
        else:
            dt = self.fixed_dt
        
        #control difference depending on control direction
        if self.reverse_act:
            self.e = -(self.x_set - self.x_act)
        else:
            self.e = (self.x_set - self.x_act)
  
            
        #Integral
        if self.Ti > 0:
            self.i = 1/self.Ti*self.e*dt + self.i
        else:
            self.i = 0
        
        
        #differential
        if dt>0 and self.Td:
            de = self.Td*(self.e-self.e_last) / dt
        else:
            de = 0
        
        
        # PID output
        self.y = self.Kp*(self.e + self.i + de)
    
        #Limiter
        if self.y < self.lim_low:
            self.y = self.lim_low
            self.i = self.y/self.Kp - self.e
        elif self.y > self.lim_high:
            self.y = self.lim_high
            self.i = self.y/self.Kp - self.e
                   
        return self.y
    
    
class Hysteresis():
    def __init__(self, lim_high=1, lim_low=0, start=False, invers=False):
        self.lim_high = lim_high #higher value
        self.lim_low = lim_low #lower value
        self.y_pre = start #output
        self.invers = invers
        
    def run(self, u): 
        y = not self.y_pre and u > self.lim_high or self.y_pre and u >= self.lim_low          
        self.y_pre = y
        
        if self.invers:
            y = not y
        
        return y
        
        


if __name__ == "__main__":
    
    PID = PID(reverse_act = True)


#    while True:
#    for i in range(10):
#        y = PID.run(x_act = 3, x_set = 2)
#        print(y)
#        time.sleep(1)
        
    hys = Hysteresis(9,1, invers=True)
    for i in range(11):
        y = hys.run(u=i)
        print(y)
        
    
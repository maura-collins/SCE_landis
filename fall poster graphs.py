# -*- coding: utf-8 -*-
"""
Created on Sun Nov 30 18:53:37 2025

@author: mraco
"""

import numpy as np
import matplotlib.pyplot as plt

#equation parameters
intercept = -2.2202
slope = 2.3922

#range of dbh values 
dbh_values = np.linspace(1, 100)

#Calculate the biomass values using the equation
#biomass = exp(intercept + slope * log(dbh))
biomass_values = np.exp(intercept + slope * np.log(dbh_values))

#carbon values are about half
carbon_values = 0.5 * biomass_values


#Original Plot, shows the exponential growth pattern 
plt.figure(figsize=(6, 5))
plt.plot(dbh_values, biomass_values, color = 'green', linewidth = 2, label = r'$\text{Biomass} = e^{-2.2202 + 2.3922 \cdot \ln(\text{DBH})}$' '\nfrom Jenkins et al. (2003)')
plt.plot(dbh_values, carbon_values, label='Carbon (0.5 * Biomass)', color = 'gray', linestyle = '--', linewidth = 2)
plt.title('Red Maple Biomass and Carbon from DBH', fontsize = 17)
plt.xlabel('Diameter at Breast Height (cm)' , fontsize = 16)
plt.ylabel('Biomass (g/$m^2$)', fontsize = 16)
plt.legend()
plt.grid(True, which = 'both', linestyle='--', linewidth = 0.5)
plt.tight_layout()
plt.show()


# Same plot but this time on a log log scale
plt.figure(figsize=(6, 5))
plt.loglog(dbh_values, biomass_values, color='green', linewidth=2, label=r'$\ln(\text{Biomass}) = -2.2202 + 2.3922 \cdot (\ln(\text{dbh}))$' '\n' 'from Jenkins et al. (2003)')
plt.loglog(dbh_values, carbon_values, label='Carbon (0.5 * Biomass)', color = 'gray', linestyle = '--', linewidth = 2)
plt.title('Log Scaled: Red Maple Biomass and Carbon from DBH', fontsize=17)
plt.xlabel('Diameter at Breast Height (cm)', fontsize=16)
plt.ylabel('Biomass (g/$m^2$)', fontsize=16)
plt.legend()
plt.grid(True, which = 'both', linestyle = '--', linewidth = 0.5)
plt.tight_layout()
plt.show() 


#combined plot, assistance with combined plot from GoogleAI
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
fig.suptitle('Red Maple Biomass and Carbon from DBH', fontsize = 17)

#Exponential graph
ax1.plot(dbh_values, biomass_values, color='green', linewidth = 2,
         label=r'Biomass — Jenkins et al. (2003)')
ax1.plot(dbh_values, carbon_values, label = 'Carbon (0.5 × Biomass)', color = 'gray', linestyle = '--', linewidth = 2)
ax1.set_title(r'Exponential: $\text{Biomass} = e^{-2.2202 + 2.3922 \cdot \ln(\text{DBH})}$', fontsize = 14)
ax1.set_xlabel('Diameter at Breast Height (cm)', fontsize = 13)
ax1.set_ylabel('Biomass (g/$m^2$)', fontsize = 13)
ax1.grid(True, which = 'both', linestyle = '--', linewidth = 0.5)

#Log log graph
ax2.loglog(dbh_values, biomass_values, color='green', linewidth = 2,
           label = r'Biomass — Jenkins et al. (2003)')
ax2.loglog(dbh_values, carbon_values, label = 'Carbon (0.5 × Biomass)', color = 'gray', linestyle = '--', linewidth = 2)
ax2.set_title(r'Log-Scaled: $\ln(\text{Biomass}) = -2.2202 + 2.3922 \cdot \ln(\text{DBH})$', fontsize = 14)
ax2.set_xlabel('Diameter at Breast Height (cm)', fontsize = 13)
ax2.set_ylabel('Biomass (g/$m^2$)', fontsize = 13)
ax2.grid(True, which = 'both', linestyle = '--', linewidth = 0.5)

#Combined legend at the bottom
handles, labels = ax1.get_legend_handles_labels()
fig.legend(handles, labels, loc = 'lower center', ncol = 2, fontsize = 11, bbox_to_anchor = (0.5, -0.08))

plt.tight_layout()
plt.show()



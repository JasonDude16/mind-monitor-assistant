## Mind Monitor Assistant 

Do you have a Muse EEG headset? Do you use Mind Monitor to view and save your raw brain wave data? If you answered yes to both of these questions, may I present to you my creatively named Shiny app... Mind Monitor Assistant. 

![](readme_gif.mp4)

The goal of this app is to make it as seamless as possible to download and view the data you gather from Mind Monitor. Using the DropBox API, you can generate a token that will allow you to download the Mind Monitor CSV files directly from the Shiny app. You can then load the data (or only part of it, e.g. 30 seconds), perform simple transformations such as downsampling and bandpass filtering, plot channels in the raw and frequency domain, and add and save metadata. 

As a next step, you could use the metadata files to select EEG data of interest, for example selecting only eyes closed resting state EEG files, and perform analyses on that subset. 


THIS IS ON THE MASTER BRANCH.

If you want to run it, please pull it and create your own workspace. Do not push anything here without permission from Zhetou/Sanjana

To run - get into preprocessing folder - following are the steps to follow

1) Run dataprocess.m -> This will load and process all the data. Loading will take some time. You will see msgs on your command window it goes through different steps

2) At some point it will enter timeprocess.m and will display a msg - "Entering timeprocess." Post this you will be asked a series of questions in your command window about various time bins for different trials. In general, you should see a plot that's being displayed, zoom in and you will see each trial starting with a red line and ending with black line. Based on your question, you will be picking start and end times.

3) Once you answer all the questions here, it will save all the timing data in a mat file and will enter object process with a msg "Entering object process." 

4) It's a function that will process different objects in the field, helmet, head fixed, head free etc. You will have a series of y/n questions. For the first time, to get familiar you can safely type in Y and continue, but eventually as you understand the code, if you happen to type N want to pick a different time bin for the question that's being asked, then you will follow the same process as above. Zoom into the plot, pick the trial you want. Type the corresponding start and end times in the command window.

For example it could display a plot and ask - "Are the markers corresponding to head coils correctly Y/N?" if Yes, type Y and if no, type N. But if you type N it will follow up with a question. "What are the correct markers.?" - Then look at the lot and type in the correct list in the command window.

Eventaully all your data will be stored in mat files and required plots will be displayed on the screen.
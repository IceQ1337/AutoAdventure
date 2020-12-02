# World of Warcraft AddOn - Auto Adventure (WiP)
[![forthebadge](https://forthebadge.com/images/badges/0-percent-optimized.svg)](https://forthebadge.com)  
[![forthebadge](https://forthebadge.com/images/badges/contains-tasty-spaghetti-code.svg)](https://forthebadge.com)  

An addon for World of Warcraft to automatically select the best setup for the shadowlands command table adventures.

## This AddOn is NOT OPERATIONAL!
## This is targeted to other AddOn developers!

I currently don't have enough time to look into a suitable algorithm to calculate the best setup based on follower/enemy abilities and I only uploaded this as a basic structure in case other people want to complete this AddOns functionality.  

The AddOn structure is fairly well-documented and does the following:

Every time the player opens the mission frame (only shadowlands adventure table) or starts a mission, the AddOn gets all available missions and followers based on their status or current health points. It then starts to "calculate" each mission if followers are available by getting a simple board overview and saving every enemy in a seperate table to make it accessible in a future analyzing function. After that, it loops through our available board spots (1-5) and through our followers and available troops (those you can use an unlimited amount of time) to get their 'FollowerAutoCombatStatsInfo'.

**This AddOn does not yet contain any logic to simulate mission outcomes.**

My idea is that the AddOn could have multiple modes using different algorithms, because calculating the best team every time based on abilities will have a massive impact on CPU and therefore game experience (FPS).  

It could for example have a mode, where only raw values such as enemy health and attack are included in the calculation. This would be very efficient performance wise, but not really if the enemy abilities are getting more complex over time.

Another option could be that the AddOn always uses all available followers or just one to complete a mission. Using more followers would increase the probability of success, but using only one follower at a time could allow the player to start multiple/more missions at once.

When I have more time to do it myself at the beginning of next year and there is still no other/better solution (such as garrison mission manager), I will look at this problem myself again. Until then, the missions must be completed by using a bit of brain power :)
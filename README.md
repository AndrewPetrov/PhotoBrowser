# Photo Browser (demo project)
 

## Disclaimer 
The task was abandoned just in the middle of developing (for reasons not related to developing), so here you can find a lot of bugs, UI is very simple on this phase. There is no design at all. Also there is autolayout engine warnings in a console. But it was completely writtrn by me.

## Goal
To duplicate **WhatsApp** built-in photo browser

## What's interesting here
The **Browser** can show items of several *types*, and has several *representations*. One of the main complexities if ability to switch representations, showing the same item despite the fact of different index. 
For example we have such input data: **Photo_1**, **Video_1**, **Photo_2**, **Photo_3**, **Photo_4**
so if representation can display Photos and Videos **Photo_2** has index **2**, if only Photos - index **1**. In this way also all actions go to the main model.

## Plans
To finish this project and make a customizable pod from it

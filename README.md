# whatthecell

This addon tracks cell usage/Pathos unlocks in Salvage. It should be invisible in any non-Salvage zone, so it can be added to your startup script with `addon load whatthecell`.

Initially it will show all pathos active and the cells to unlock them, as this is the state you should be in on entering salvage. As you use an unlock cell, the pathos associated with it will fall off the list. Below is a video showing this in action (Wizard Cookie isn't a tracked unlock item/pathos in the final version, this was just added for testing purposes outside of salvage.)

https://github.com/ConteAlmaviva/whatthecell/assets/8880996/3599d185-365e-4463-9f73-ccecb3390f29

As is, the addon will not preserve pathos unlock state if you logout and log back in (or disconnect). This could be added in a future version if needed.

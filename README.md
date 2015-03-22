# chilifx
ChiliFX: Library for creating effects for ChiliUI

Dependencies:
- LCS: https://github.com/gajop/chiliui
- ChiliUI: https://github.com/gajop/chiliui

Usage:

```lua
ChiliFX = WG.ChiliFX -- do this only once in your project

-- Glow effect multiplies the RGB channels of an object
ChiliFX:AddGlowEffect({
    obj = myObject, -- chili object
    time = 3, -- time the effect should last
    startValue = 1, -- optional (1 being the default)
    endValue = 1, -- goal value of the glow before ending
    after = function()
        -- stuff to do after the effect ends
    end
})

-- Fade effect, multiplies the alpha channel of an object
ChiliFX:AddFadeEffect({
    obj = myObject, -- chili object
    time = 3, -- time the effect should last
    startValue = 1, -- optional (1 being the default)
    endValue = 1, -- goal value of the fade before ending
    after = function()
        -- stuff to do after the effect ends
    end
})
```

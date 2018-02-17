-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- Overrides some inbuilt spring functions

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- Scaling
-- hack window geometry

-- gl.GetViewSizes intentionally not overridden
Spring.Orig = Spring.Orig or {}
Spring.Orig.GetWindowGeometry = Spring.GetWindowGeometry
Spring.Orig.GetMouseState = Spring.GetMouseState

Spring.GetWindowGeometry = function()
	local vsx, vsy, vx, vy = Spring.Orig.GetWindowGeometry()
	return vsx/(WG.uiScale or 1), vsy/(WG.uiScale or 1), vx, vy
end


Spring.GetMouseState = function()
	local mx, my, left, right, mid, offscreen = Spring.Orig.GetMouseState()
	return mx/(WG.uiScale or 1), my/(WG.uiScale or 1), left, right, mid, offscreen
end

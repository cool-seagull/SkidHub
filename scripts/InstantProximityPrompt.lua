local function makePromptInstant(prompt)
	if prompt:IsA("ProximityPrompt") then
		prompt.HoldDuration = 0
	end
end

-- Existing prompts
for _, obj in ipairs(workspace:GetDescendants()) do
	makePromptInstant(obj)
end

-- New prompts added later
workspace.DescendantAdded:Connect(function(obj)
	makePromptInstant(obj)
end)

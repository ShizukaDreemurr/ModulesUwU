return function(team)
  game:GetService("ReplicatedStorage").Remotes["CommF_"]:InvokeServer("SetTeam", team)
  local makeVisible = {
      "Compass",
      "Energy",
      "AlliesButton",
      "Code",
      "CrewButton",
      "HomeButton",
      "Mute",
      "Settings",
      "MenuButton",
      "Beli",
      "Fragments",
      "Level",
   -- "Radar",
      "HP",
  }
  if game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam") then
      game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam"):Destroy()
  end
  local makeVisibleSpecial = {
      "RaceEnergy",
  }
  for i,v in pairs(makeVisible) do
      game:GetService("Players").LocalPlayer.PlayerGui.Main[v].Visible = true
  end
  game:GetService("Workspace").CurrentCamera.CameraType = Enum.CameraType.Custom
  game:GetService("Workspace").CurrentCamera.CameraSubject = game:GetService("Players").LocalPlayer.Character.Humanoid
  game:GetService("Workspace").CurrentCamera.CFrame = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
  for i,v in pairs(makeVisibleSpecial) do
      if v == "RaceEnergy" then
          if game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Awakening") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Awakening") then
              game:GetService("Players").LocalPlayer.PlayerGui.Main[v].Visible = true
          end
      end
  end
end

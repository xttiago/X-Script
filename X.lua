local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shhskshdjsjsjsh-source/RedzHubUI/refs/heads/main/README.md"))()

local Window = redzlib:MakeWindow({
  Title = "X - Universal",
  SubTitle = ".",
  SaveFolder = "Xv1.lua"
})

local Tab1 = Window:MakeTab({"Test", "cherry"})

Tab1:AddButton({"Print", function(Value)
print("X")
end})
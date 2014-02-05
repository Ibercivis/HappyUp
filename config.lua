settings =
{
        orientation =
        {
                default = "portrait",
				supported = { "portrait", "portraitUpsideDown" }
        },
		iphone =
		{
			plist =
			{
                            CFBundleIconFile = "Icon.png",
                            CFBundleIconFiles = {
                                "Icon.png", 
                                "Icon@2x.png", 
                            },
                            UIAppFonts =
                            {
				"Prime.ttf"
                            },
                            UIPrerenderedIcon = true,
			},
		}
}application = 
{
	content = 
	{ 
		width = 320,
		height = 480,
		scale = "letterbox",
		fps = 60,
		
		imageSuffix = {
			["@2x"] = 2,
		}
	}
}
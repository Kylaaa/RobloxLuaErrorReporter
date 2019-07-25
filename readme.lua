--[[
		Lua Error Reporter - by ItReallyIsKyler

	This package is designed to allow you to easily get analytics on scripts
	that might throw errors in your published games.


		Things to Know
	When you run the game, this package will place a few items into your Workspace :
	ReplicatedStorage
		> ErrorReporting -	This Folder contains a RemoteEvent called ClientErrorEvent.
							This is placed here as a known location so that our server and client scripts
							can both locate it.
							If there is already something in ReplicatedStorage with this name, it will
							throw an error and you will have to handle the collision for it to work.

	StarterPlayer.StarterPlayerScripts
		> ErrorObserverClient - This LocalScript will get copied into every player that joins.
								It will listen for clientside errors, and fire the ClientErrorEvent
								RemoteEvent to pass this information back to the server.



		Getting Started
	1) Move this Folder into ServerScriptService. While it can work properly if placed directly in
		the Workspace, Config will contain sensitive information that you likely do not want
		to be publicly visible to any player that joins.
	2) Open the ModuleScript named Config and set the appropriate variables.
		By default, this module will try to report your data to GoogleAnalytics, but you will have
		to configure it with the appropriate tracking ID.
	3) Turn off any verbose messages when you are happy that everything is working properly.


		Configuring Google Analytics
	1) If you have not signed up for Google Analytics, go to : https://analytics.google.com/
		1.a) Hit Signup
		1.b) Configure your account for a Website
		1.c) Account Name - Use your business name, or your website name if you have one
		1.d) Website Name - Make this the name of your game
		1.e) Website URL - A real website is highly recommended, but https://roblox.com is acceptable
		1.f) Industry Category - Games
		1.g) Scroll down and Hit Get Tracking ID
		1.h) Accept the Terms and Conditions. **** You are liable for following data storage laws ****
		1.i) You are now on the correct page, skip to step 3
	2) Open the Admin Panel in the lower left corner, click on Property > Property Settings
	3) Copy the Tracking Id
	4) Open the Config ModuleScript and update the GOOGLE_ANALYTICS_TRACKING_ID value


		Configuring for PlayFab
	* This feature is currently only available for developers in the beta program. *
	* If you have not received an invitation, these steps will not work for you. *

	These instructions can also be found : https://developer.roblox.com/en-us/articles/using-the-analytics-service
	1) Log into your PlayFab dashboard at https://developer.rblx.playfab.com/en-US/sign-up
	2) Find your game, and copy the string of characters under the name.
	3) Open the Command Bar in Studio
	4) Enter the text : game:GetService("AnalyticsService").ApiKey = "<YOUR_COPIED_API_KEY>"

	Now, when you publish your game, you should see data starting to flow into your dashboard.
]]
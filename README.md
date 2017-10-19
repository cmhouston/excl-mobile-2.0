# ExCL Developer Documentation #
A guide for setting up Titanium and beginning mobile development with ExCL

### Contents ###

1. [Introduction to ExCL](#exclIntro)
- [WordPress](https://github.com/cmhouston/excl-cms#wordpress)
- [Adobe Air And FlashDevelop](#adobeair)
     - [Introduction to Adobe Air](#introToAdobeAir)
     - [Getting Started](#gettingStarted)
     - [Running the ExCL App](#runningExCL)
     - [Debugging](#debugging)
     - [Code Overview](#codeOverview)                       
- [Enhancing the ExCL App](#enhancingExCL)            
- [Distribution For Testing](#addhoc)
- [Deploying to the App Store](#appStore)
- [Known Issues](#knownIssues)
- [Contributing](#contributing)

# <a name="exclIntro"></a> Introduction to ExCL #
ExCL is a global initiative to change the way people learn.  It seeks to empower museums to create their own mobile applications that they can use to inspire, educate, and connect with their visitors. Content is managed through a WordPress content management system by museum staff, and visitors will download the customized ExCL app, written using [Adobe Air](http://www.adobe.com/products/air.html), to their mobile device. ExCL is also intended to be used by museums on kiosk devices and provides a kiosk mode for this purpose.

ExCL is divided into two parts: the content management system and the Adobe Air mobile application. This repository is for the Adobe Air mobile application. If you're interested in the content management side, click here to go to the [Wordpress project](https://github.com/cmhouston/excl-cms).

This documentation is intended for ExCL developers and details the steps to setup and enhance the mobile application. We will describe the Adobe Air technical details, followed by tips on using a continuous integration build server and deploying to the app stores.

# <a name="adobeair"></a>Adobe Air #

## <a name="introToAdobeAir"></a> Introduction to Adobe Air ##

Adobe Air is a tool that allows developers to create applications for multiple platforms using a single project. For this project we are using Adobe Air in order to support both iOS and Android operating systems. 

Adobe Air provides many useful features and examples, which can be found under the [Adobe Air SDK Documentation](http://www.adobe.com/devnet/air/documentation.html) 

## <a name="gettingStarted"></a> Getting started ##

### Install FlashDevelop ###

FlashDevelop is a free and open source (MIT license) source code editor. FlashDevelop allows developers to [download FlashDevelop](http://www.flashdevelop.org/) for free. No account setup is needed.

### Import ExCL to FlashDevelop ###


#### Clone the repository ####
In order to view and edit the ExCL project using FlashDevelop the project must be retrieved from github. We recommend that if you want to customize ExCL to your own museum extensively, that you consider [forking the project](https://help.github.com/articles/fork-a-repo) and then cloning the fork. The master ExCL project contains generalized icons and will need to be customized before released as your own application.

##### Using Command Line #####

If you are using a Mac or Linux computer, you go ahead and clone the repository. If you are using a windows machine, make sure you install git first. Here is a site that explains the process for [Installing Git](http://git-scm.com/book/en/Getting-Started-Installing-Git).

Open a command prompt, navigate to a desired folder run the following command:

     $ git clone https://github.com/cmhouston/excl-mobile-2.0.git

##### Using SourceTree #####

A different tool for handling repositories and source control is [SourceTree](https://www.atlassian.com/software/sourcetree/overview?_mid=36679bc382faa46de63d9de67e0aca61&gclid=Cj0KEQjwx4yfBRCt2rrAs-P5vtkBEiQAOdFXbXiQRjxGbz923Us5QtTmaahoNHqrzWUEB3eMWQsJnfwaAlkA8P8HAQ). Install SourceTree and clone the repository into your local file system.

#### Import Project Into FlashDevelop ####

After the project has been cloned to your local system execute the following steps to access it through your IDE

1. Open FlashDevelop and go to File->Import
- Select Titanium->Existing Mobile Project and click next
- Browse your local file system and choose the folder you cloned from github
- Inside the folder select the More_App.as3proj file.

To run the app simply press F5.


### First time setup ###

After importing the project into FlashDevelop, open up the `bin/config.xml` file. You will need to put in the endpoint URLs that point to the [ExCL Wordpress instance](https://github.com/cmhouston/excl-cms) that you have already set up. The endpoints should look like `http://myserver.com/wp-json/v01/excl/museum/25`.

You get the ID number on the end of the URL from the ID of the museum in the Wordpress instance. This can be easily seen in the URL bar when editing the museum page in Wordpress.

Additionally, the app should be customized to fit your organization. Update the images in the `splash screens` folders and update `bin/config.xml` to reflect your own organization's information.

## <a name="runningExCL"></a> Running the ExCL Application ##

FlashDevelop is designed to easily deploy and simulate projects for multiple platforms using Adobe Air. 


### <a name="iosdeployment"></a> iOS Device Deployment ###

To deploy to an Android device please see the [AIR_iOS_readme.txt](AIR_iOS_readme.txt) file in the root of the repository

### <a name="androiddeployment"></a> Android Device Deployment ###

To deploy to an Android device please see the [AIR_Android_readme.txt](AIR_Android_readme.txt) file in the root of the repository

If your computer does not recognize your Android device it is also possible to manually install the app.

1. Enable Unknown Sources in the Device's settings app
- Connect the device to the computer via USB
- Build the Application by running it on an Android Emulator
- Navigate to (Project Folder)/build/android/bin on the computer and retrieve the APK file
- Copy this file to the Downloads folder on the device
- Disconnect your device and navigate to the APK file to install

## <a name="debugging"></a> Debugging ##

When using the built in Emulators debugging is very simple. Refer to Adobe Air's documentation for [Debugging on the Emulator or Simulator](http://help.adobe.com/en_US/air/build/WSfffb011ac560372f20b57e08128cc91aa2f-7ffe.html). 


1. To run the app for Testing and Debugging
- open bat/RunApp.bat and under :target you will be able to set your build out option (Android, iOS, or desktop.
- if building for desktop set the desired resolution under :desktop heading in bat/RunApp.bat
- Press F5 to build and run (if building for iOS or Android the app will be loaded on the corresponding connected device).

Under the Desk

## <a name="codeOverview"></a> Code Overview ##

### Framework ##

ExCL makes use of an embedded SQL database.  The database is used to save tutorial on/off settings as well as the settings for age filtering of posts.   All of the functions related to saving/ retrieving data are found in [DataManasger.as](src/utilities/DataManager.as).

ExCL also uses the [GoViral.ane extension by Milkman games](https://www.milkmanplugins.com/goviral-facebook-and-sharing-air-ane) but it is not neccessary for the app to function.  In the case that the extension is not used the "sharing" tag in config.xml needs to be set to false.  In addition the following lines must be commented out from application.xml found in the root of the repository.

	<extensions>
	     <extensionID>com.milkmangames.extensions.GoViral</extensionID>
	</extensions>

Adobe Air allows developers to store global information. in ExCL all global variables are created from [GlobalVarContainer.as](src/GlobalVarContainer.as). Many of the Global Variables are set in [config.php](bin/config.php).  [GlobalVarContainer.as](bin/GlobalVarContainer.as) also parses the exhibit/ component/ post data. 



### Considerations while using ExCL ###

- The majority of screens are handled by [MainInterface.as](src/MainInterface.as).
- All fonts and colors are defined within the configuration file: [config.xml](bin/config.xml)


# <a name="enhancingExCL"></a> Enhancing the ExCL App #

ExCL is now in version 2.0.  It was created based on feedback and reccomendations of the v1.4 users.  The app is programmed in such a way as to make better use of device screen surface area and to provide a smoother navigation than previous versions.


## UX Enhancements to Current Features ##

The following is a list of some of the improvements from v1.4 ro v2.0

- Improved display of posts while age filtering is turned on.
- Better usage of screen space on most page layouts.
- Smoother navigation of exhibit's component slider on the Exhibits page.
- Cropped thumbnails and images throughout to allow for consistent layout
- Added a tutorial screen to Maps and Info pages in the case user views those pages prior to viewing the Exhibits page.
- Added Pinch-zoom tutorial to Maps page.
- Removed uneccessary display page under Info. 
- Added additional loaders and smoother page transitions

## Technical Enhancements ##

- Fixed issue with some images and content not loading due to erroneous Word Press entries
- Fixed issue with the app crashing in Kiosk Mode
- Email and text sharing of posts working with optional GoViral plugin
- Database saves/ retrieves selected Age Filters

## Reporting Bugs ##

Please report all bugs to our [CMH account](mailto:rmanassya@cmhouston.org)


Regardless of which service you use (if any at all), instructions for building for device deployment can be found here:

- [iOS Device Deployment](#iosdeployment)
- [Android Device Deployment](#androiddeployment)

# <a name="appStore"></a> Deploying to the App Store #

Both Google and Apple provide documentation about their app store requirements. These can be found at their developer sites:

- [Android Launch Checklist](http://developer.android.com/distribute/tools/launch-checklist.html)
- [iOS App Store Guidelines](https://developer.apple.com/appstore/resources/approval/guidelines.html)

# <a name="knownIssues"></a> Known Issues #

- Images are not attached using the GoViral plugin for Android.  Only text is currently shared. 

_______

# <a name="contributing"></a> Contributing #

We welcome contributions to this code. In order to contribute, please follow these steps:

1. Fork this repository
2. Make your changes
3. Submit a pull request to have your changes merged in
4. The pull request will be reviewed by our core team and possibly merged into the master branch


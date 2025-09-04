## Get Started
Install the app : Build and deploy from VS Code, change launch.json settings for your server. The BC xliff Manager app can be installed both on a Cloud Sandbox, a Docker Image or an onPrem BC tenant.


### Choose the Translate role for users using the tool

![A user interface screen showing the process of assigning the Translate role to a user in BC xliff Manager. The screen displays a list of roles with Translate highlighted or selected. The environment appears to be a business application dashboard with navigation menus and role options. The tone is neutral and instructional. Visible text includes Setting Translate Role.](/.assets/setup-role.png)

This will give you the following 

### Starting configuration

![Business Central Role Center for the Translate App, showing number of projects and with links to setup app and projects](/.assets/setup-role-center.png)

Start by opening the **Translation Setup**

![Translation Setup Page letting users choose AI engine for translation, Default language](/.assets/setup-translation-setup.png)

**Start** by clicking the "Initialize ISO Languages" button. 
This will augment the language table with the BC supported ISO language/culture codes. 

**Choose** Default source language. This will almost always be ENU

### AI Translate Tools
Here you can choose which, if any, machine translate tool you will use. 

The free Google Translate API has some rate limits, which means you may be limited in how many texts you can process at a time. 

If you have an OpenAI API subscription, generate a key for the Translate app and enter that here. 

You can add new models in the GPTTranslate Codeunit, the two currently to choose from : gpt-3.5-turbo and gpt-4o both have low costs, between $0.1 and $0.5 per 1000 labels. 
Experiment with the models, or change the system prompt to get the best possible results. 
As with all AI models, once in a while it will seemingly ignore what you asked it and return some additional information or something like that, so always do an inspection of the translations.

Now you are ready to **[Create you first project](/.assets/Projects.md)**
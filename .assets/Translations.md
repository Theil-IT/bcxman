## Work with Translations

Once your Target Languages are defined you can start to enter the translations that are missing. 


### Manual translation

Manual translation is simple, you just open the list of Translation Targets by clicking **Translation Target** for a Language in the Target Languages list. This open the list of Translation targets:

![Translation Targets](/.assets/translation-typemanual.png)

You just type in your translation of the terms. If a term occurs more than once in all your project, you will be prompted if you want to copy the translation to all the other occurences. 

![Copy Target](/.assets/translation-copytarget.png)

You can click **Select Empty Translatios** to see just texts with missing translations. Or use any filtering you like on th elist page as per usual BC operation.


### Machine guided translation

If you have turned on either Google Translate or Open AI translation tools, you can use those to help translate the texts. Clicking **Translate** will translate the single target text you currently have selected. 

Clicking **Translate All** will translate all Texts, and prompt you if you only want to translate texts that are missing a translation. 
Translate all will always only translate texts that have a checkmark in the "Translate" field, and will clear the field after successfull translation.

![Translate All](/.assets/translation-allselection.png)

The first time you use this you will get the usual dialog to accept service calls to the internet: 

![Allow Always](/.assets/translation-allowalways.png)

Just click Ok to continue and a counter will show how many texts have been translated out of the total. 

#### Free Google Translate vs. OpenAI

Here is the generated translation from Google Translate for our small sample: 

![Google Translate results](/.assets/translation-google.png)

You will notice (If you know some Danish) it leaves some typical Google-translate like trails. Now there are ways to fix some of it using the [Translation Terms](#translation-terms) functionality. 

If you use the OpenAI translation, here is an example of what the translation generates:

![OpenAPI Translation](/.assets/translation-openai.png)

Here we also see something that looks a bit off. None of the machine translations have the correct translation on Lead Time Calculation, which in the the base BC is translated to "Leveringstid" og "Leveringstidsberegning" when using Danish Language. 

The other thing is that our little test project here calls itself "Trans Tool", we want that to be the name in all languages and the machine translation in both cases struggle maintaining that as a non-translated term, even has some quirky translations. 

We will solve this first, and then get back to how to best address the Lead Time Calculation issue.

### Translation Terms

For each project, and for each language you can configure specific translation Terms, and the system will then apply these terms depending on the setup. Here we setup translation for Trans Tool and for the wrong translation of Lead Time: 

Go to the project list and select the project you are working on. Then choose the **General Translation Terms** action to open the list of project wide translation terms. Add the "Trans Tool" term and toggle the "Apply Pre-Translation" flag:

![General Translation Terms](/.assets/translation-gen-terms.png)

Go back to the Project list and open the list of Target languages , select the language you want to define a term exception for, here Denmark, and click the **Translation Terms** action. 

![Per Language Translation Terms](/.assets/translation-lan-terms.png)

So after these adjustments, and switching to the gpt-4o model for OpenAI we get this result:

![Final Translation with terms defined](/.assets/translation-with-terms-4o.png)

So for all languages the **Trans Tool** project name will remain untranslated. For specifically Danish language, the term we defined will be replaced post-translation with the corrected version. 

And here is the same project with gpt-4o translations for Swedish, note the "Trans Tool" project name has been preserved (At the moment this pre-translate term-preservation doesn't work for the Google Translate based translation - working on that)

![Swedish Translation](/.assets/translation-with-terms-sve-4o.png)

To get an even better translation, set up a **[Reference Project](/.assets/Projects.md#reference-projects)


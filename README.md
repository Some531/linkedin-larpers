# Linkedin-Larpers

# Branches: 
- imira (backend)
- hamza (frontend)
- swornim (idea generation, plan formulation)

# Assessment criteria

Problem Definition (supported by evidence): 20%
Strategy/Solution: 50%
What Does Success Look Like?: 10%
Delivery and Presentation: 20%

# Pre-brief requirements

The solution will require a technology solution that addresses a particular theme, the backend and frontend will be created separately, then merged together.

# Theme

### Brief: Disaster and Emergency Management

Focus on hard-to-reach communities (culturally and linguistically), as they do not trust information provided. Some considerations:

- The information is usually text-heavy, full of jargon, and a matter of poor communication
- Alerts are not translated properly
- Response information often comes through apps; there is an assumption that people download those apps
- People who need support most don't have access to information. The groups can be minor, remote, or indigenous communities, and they should be clearly defined.
- More than one phase can be selected, but the focus should be stated
- It's not only technology that is at stake, but there are also psychological and social factors involved
- A good solution has to incorporate the same process: receiving it, understanding it, believing it, and acting on it
- Warning fatigue can lead to reduced effectiveness, as well as information overload
- *Refrain from AI-slop!*

A key consideration is the fact that being physically close is not enough and that lack of online presence can predispose these individuals to risks. 

#### Phases: 
- Prevention (avoid before it happens)
- Preparedness (prepare people)
- Response (acts taken when it does happen)
- Recovery (restore communities)

# Things to consider in approach to ideation

Think carefully where the issues are, collect evidence to ensure that the issue is significant and how this may be addressed in terms of the phases. Intervention may occur in multiple phases to mitigate impact. Address hierarchy in remote communities. Have a clearly defined community (culturally and linguistically) in the Asia Pacific Region. Trust and accessibility are very important. How will it operate, practically speaking? Think about connectivity. What alternative solutions might be considered? The solution must be based on a community need.

# Why Culturally and Linguistically diverse communities are more vulnerable

- Language barriers
- Limited social networks
- Limited local risk knowledge
- Reduced access to trusted information and services

Use evidence from real, past disasters. Context is important, so people from different backgrounds may not understand terms like "tsunami" in their native language (meaning lost through translation).

# Features

- Live map: the user accepts permissions for the app to use the user's location. Visually, the user's location around them (1 km radius) can be zoomed in and out. Landmarks/import locations get highlighted, like hospitals. Users' data may be used, like elevation to determine risk for tsunamis, to create personalised alerts and prevention plans. An open source will be used
- Determining risk: Existing data from the ABS or government websites relevant to the user's country/region can be used to determine plans. Also, the user's personal/local location can be used in addition to give personalised plans/recommendations
- Chatbot: The user can ask any questions if they are unsure about navigation or what certain terms mean
- Accessibility: Standard UI principles should be applied to account for people with disabilities and elderly people (e.g. enlarged text). The app should support several languages. Text-to-speech for the chatbot
- Risk classification: An SMS message is sent to the user, outlining the risk classification (can be traffic-lighted), with emoji symbols to denote what kind of disaster. It must be clear what phase it is referring to (as the disaster will happen soon, it is happening now). This SMS should be simple; the text should be concise and clear, free of jargon. The SMS will have a link to the app, where the app will have more detail
- Use of symbols: symbols to convey meaning

# Platform

iOS application for iPhone. SMS notifications are sent to the user containing a link into the app, where the content the SMS covered is set out in more detail.

# Filipino Dialects
Tagalog
Cebuano (Bisaya/Binisaya)
Ilocano (Ilokano)
Hiligaynon (Ilonggo)
Bikol (Central Bikol / Bicolano)

# Disasters - Consider emergency protocols for each disaster
Typhoons - storm surges, heavy rainfall, winds

Flash floods, triggered by other disasters

Landslides, in mountainous, deforested, or steep areas

Earthquakes - Frequent small ones, rarer large ones. 

Tsunamis

Volcanic Eruoptions

Wildfires, during dry season

Droughts

Tornadoes

# OpenStreetMAP open source maps to track user's location

https://www.openstreetmap.org/export#map=4/6.49/139.66

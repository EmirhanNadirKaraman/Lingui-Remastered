# Lingui

**Problem Definition:** If a language learner watches videos they cannot understand, or videos that are way below their language level, they will not learn anything. In order for the learner to improve their language level, they have to get input that is both comprehensible and challenging to them. This is known in the linguistic community as Input Hypothesis [1, 2]. However, language learners do not have a platform for finding video content that is suited to their language level and their vocabulary knowledge. 

**Project Description:** We propose an app solution, in which users will be able to find personalized YouTube content, tailored to their vocabulary at that time. The videos will be prioritized according to the set of words they are currently learning. 
Firstly, there will be a test consisting of 5 videos, in which users will mark the words they do not know. After that, the algorithm will select videos that contain sentences that are challenging, but comprehensible to the user. 

New words will be taught to the user by a spaced repetition system, and this feature will ask cloze test questions to the user to see if they really learned the word.

**Solution:**
- The videos and their subtitles will be retrieved from the YouTube API.
- The vocabulary of the user will be stored in our database. 
- This vocabulary knowledge will be used to pick the videos appropriate for the user.
- Any words that have been encountered more than a constant amount of times will be added to the user’s “Words to Learn” list, as the user will start to notice these -words more and more due to the Baader–Meinhof phenomenon [3]. 
- Words will be removed from this list if the user succeeds in the cloze test, and added to the “Known” list. 

**Project Documents:**
1. [Specification Report](docs/SpecificationReport.pdf)
2. [Analysis and Requirements Report](docs/AnalysisReport.pdf)
3. [Detail Design Report](docs/DetailDesignReport.pdf)
4. [Final Report](docs/2336_FinalReport.pdf)

**References:**
1. https://en.wikipedia.org/wiki/Input_hypothesis#cite_note-Krashen1977-1
2. https://www.leonardoenglish.com/blog/comprehensible-input#toc-0
3. https://en.wikipedia.org/wiki/Frequency_illusion

**Further Reading:**
1. https://refold.la/introduction
2. https://www.youtube.com/c/MATTvsJapan


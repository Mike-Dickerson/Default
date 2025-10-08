# Default
Default Repo Setup

Mostly this is all about the AI Agent Rules file included th Claude.MD is a set of AI Agnet rules that I've worked on
in using Claude, ChatGPT, Cursor, Q etc... agents.  This helps a LOT with the tendency of AI Agents to "code ahead", add 
"enahncemnts" and place_holders, and arbitrary limits and anythiing else I've found.  

If you come up with additional rules, PLEASE send me the pull request.  Let's make this into a workable ruleset to save
uncountable hours of ghost chasing..

Added a new one today.  A brain container that's local to my dev machine. baiscally a psql container with structures to
enable reading/writing of "memories" for claude to use. include the intructions.md in your project folder and when you start
Claude, you can use /brain or [brain] and keywords. then start discussing from there.  

Use this template to start your project. Go into the claudebrain folder and "docker compose up -d"   After it starts Then start Claude
and the instructions.md will tell claude to use his new persistent memory.  You only need to start teh container once. Any instance of 
Claude (as long as its stated with this instructions.md) will know about persistent memory and what's been going on in the world. 

Have fun with it

Mike

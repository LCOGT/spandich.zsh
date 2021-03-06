#!/usr/bin/env groovy

import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import static java.lang.System.exit

/*
 * Copyright (C) 2015  Las Cumbres Observatory <lcogt.net>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

class CreateSprintWiki {

    static final String PIVOTAL_API_VERSION = "5";
    static final String PIVOTAL_PROJECT_ID = "1314272";
    static final String PIVOTAL_API_TOKEN = "bad8c2be8f551376936246cfd4291d0b";
    static final String PIVOTAL_API_BASE_URL = "https://www.pivotaltracker.com/services/v${PIVOTAL_API_VERSION}"
    static final String PIVOTAL_API_PROJECTS_URL = "${PIVOTAL_API_BASE_URL}/projects/${PIVOTAL_PROJECT_ID}"
    static final String ROLLED_SPAN_CSS='font-weight: bold; color: blue;'
    static final String STORY_HR_CSS = 'width: 200px; height: 2px; color: #D0; margin-bottom: 4em; margin-top: 2em;'
    static final String BLOCKQUOTE_COMMON = '<span style="color: #ccc; font-size: 3em; line-height: 0.1em; vertical-align: -0.3em;">'
    static final String BLOCKQUOTE_BEGIN = "${BLOCKQUOTE_COMMON}<span style=\"margin-right: 0.15em;\">&#8220;</span></span><span style=\"display: inline;\";>"
    static final String BLOCKQUOTE_END = "</span>${BLOCKQUOTE_COMMON}<span style=\"margin-left: 0.15em;\">&#8221;</span></span>"

    static void fetchStories(final int sprintNumber) {


        final String projectJson = new URL(PIVOTAL_API_PROJECTS_URL).getText([
                requestProperties: [
                        ('X-TrackerToken'): PIVOTAL_API_TOKEN,
                ]
        ])
        final project = new JsonSlurper().parseText(projectJson)
        final int velocity = project.initial_velocity

        int totalPoints = 0
        int totalStories = 0
        String wikiStories = ''

        final String storiesUrl = "${PIVOTAL_API_PROJECTS_URL}/iterations?scope=current"
        final String storiesJson = new URL(storiesUrl).getText([
                requestProperties: [
                        ('X-TrackerToken'): PIVOTAL_API_TOKEN,
                ]
        ])

        boolean firstStory = true
        final iterations = new JsonSlurper().parseText(storiesJson)
        iterations.each { final iteration ->
            iteration.stories.findAll { final story -> story?.story_type != 'chore' }.each { final story ->

                if (!firstStory) {
                    wikiStories += "<hr style=\"${STORY_HR_CSS}\" />"
                } else {
                    firstStory = false
                }
                totalStories++
                int storyPoints = 0
                try {
                    storyPoints = (story?.estimate ?: 0) as int
                } catch (NumberFormatException ignore) {
                }
                totalPoints += storyPoints
                wikiStories += """
===${story.name}${story.current_state == 'planned' ? '' : "&nbsp;<span style=\"${ROLLED_SPAN_CSS}\">(rolled over)</span>"}===
*'''Story:''' ''${BLOCKQUOTE_BEGIN}${story.description.replaceAll(/(^[ \n\t]*|[ \n\t]*$)/, '') ?: 'none'}${BLOCKQUOTE_END}''
${storyPoints ? "*'''Points:''' ${storyPoints}\n" : ''}"""

                final String tasksUrl = "${PIVOTAL_API_PROJECTS_URL}/stories/${story.id}/tasks"
                final String tasksJson = new URL(tasksUrl).getText([
                    requestProperties: [
                            ('X-TrackerToken'): PIVOTAL_API_TOKEN,
                    ]
                ])
                final tasks = new JsonSlurper().parseText(tasksJson)
                if (tasks) {
                    wikiStories += "*'''Tasks:'''\n"
                    tasks.each { final task ->
                        wikiStories += "** ${task?.description ?: 'none'}\n"
                    }
                }
            }
        }
        
        print """
*'''Stories:''' ${totalStories}
*'''Points:''' ${totalPoints}
*'''Days in Sprint:''' 10
*'''Estimated Team Velocity:''' ${velocity}
*'''Other notes:''' <em>None</em>

==Documents==

[[Media:Softies_sprint_${sprintNumber}_demo.pdf|Sprint ${sprintNumber} Demo]]
        
==Stories==
${wikiStories}

[[Category:Software]]
""".replaceAll(~/\[(.+?)\]\((.+?)\)/, '[$2 $1]')
    }


    static void main(final String[] args) {
        if (args.length != 1) {
            println "Usage: create_sprint_wiki sprint_number"
            exit 1
        }

        int sprintNumber = 0
        try {
            sprintNumber = args[0] as int
        } catch (NumberFormatException ignore) {
            println "Error: invalid sprint number '${args[0]}'."
            exit 1
        }

        fetchStories(sprintNumber)
    }
}

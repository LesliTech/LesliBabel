/*
Copyright (c) 2022, all rights reserved.

All the information provided by this platform is protected by international laws related  to 
industrial property, intellectual property, copyright and relative international laws. 
All intellectual or industrial property rights of the code, texts, trade mark, design, 
pictures and any other information belongs to the owner of this platform.

Without the written permission of the owner, any replication, modification,
transmission, publication is strictly forbidden.

For more information read the license file including with this software.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · 
import { defineStore } from "pinia"


// · 
export const useString = defineStore("babel.string", {
    state: () => {
        return {
            component: "",
            string: {
                bucket_id: null,
                context: "",
                label: ""
            }
        }
    },
    actions: {

        updateString(string, locale=false) {
            clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                this.putString(string, locale)
            }, 1500)
        },

        putString(string, locale=false) {

            // we need to send only properties that we can update
            let stringToUpdate = {
                status: string.status,
                context: string.context,
                priority: string.priority,
                need_help: string.need_help,
                need_translation: string.need_translation
            }

            // if locale send then we update only the specific translation
            if (locale) {
                stringToUpdate[locale] = string[locale]
            }

            this.http.put(this.url.babel("strings/:id", string.id), {
                string: stringToUpdate
            }).then(result => {
                this.msg.success("Translation updated successfully")
            }).catch(error => {
                console.log(error)
            })
        },

        post() {
            this.http.post(this.url.babel('strings'), {
                string: {
                    bucket_id: this.string.bucket_id,
                    context: this.string.context,
                    label: this.component + "_" + this.string.label
                }
            }).then(result => {
                this.msg.success("Label successfully added")
                this.string.label = ""
            }).finally(() => {
                
            })
        }
    }
})

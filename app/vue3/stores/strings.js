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
export const useStrings = defineStore("babel.strings", {
    state: () => {
        return {
            ids: null,
            showPanel: false,
            language: 'en',     // working language
            timer: null,
            search: "",
            module: 0,
            bucket: 0,
            strings: { 
                loading:false, 
                records:[], 
                pagination:{} 
            }
        }
    },
    actions: {

        fetchSearch(search) {
            this.search = search
            this.fetchStrings()
        },

        fetchRelevant() {
            this.strings.loading = true
            this.strings.records = []
            this.http.get(
                this.url.babel("strings/relevant")
                .paginate(this.strings.pagination.page, 100) // get the first 100 missing translations
                .order(this.language)
            ).then(result => {
                this.strings.records = result.records
                this.strings.pagination = result.pagination
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.strings.loading = false
            })
        },

        fetchStrings() {

            this.strings.loading = true
            this.strings.records = []

            let params = {}

            if (this.module > 0) { params['module'] = this.module }
            if (this.bucket > 0) { params['bucket'] = this.bucket }

            let url = this.url.babel("strings", params)
            
            if (this.search != "") {
                url = url.search(this.search)
            }

            // requested specific labels through id
            if (this.ids != null) {
                url = url.query("ids", this.ids)
            }

            this.http.get(url).then(result => {
                this.strings.records = result.records
                this.strings.pagination = result.pagination
            }).catch(error => {
            }).finally(()=>{
                this.strings.loading = false
            })
        },

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

        post(string) {
            this.http.post(this.url.babel('strings'), {
                string: string
            }).then(result => {
                if (!result) {
                    this.msg.error("Error adding label")
                    return
                }
                this.msg.success("Label successfully added")
            })
        }
    }
})

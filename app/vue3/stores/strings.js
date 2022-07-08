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
            timer: null,
            search: "",
            relevant: { 
                loading:false, 
                records:[], 
                pagination:{} 
            }
        }
    },
    actions: {
        putString(string) {
            clearTimeout(this.timer)
            this.timer = setTimeout(() => {
                this.http.put(this.url.babel("strings/:id", string.id), {
                    string: string
                }).then(result => {
                    this.msg.success("Translation updated successfully")
                }).catch(error => {
                    console.log(error)
                })
            }, 1500)
        },

        fetchRelevant() {
            this.relevant.loading = true
            this.http.get(this.url.babel("strings/relevant")).then(result => {
                this.relevant.records = result.records
                this.relevant.pagination = result.pagination
            }).catch(error => {
                console.log(error)
            }).finally(() => {
                this.relevant.loading = false
            })
        },

        fetch(search) {
            this.loading = true
            
            let url = this.url.babel("strings/search").search(search)

            /*

            let url = `/babel/strings/search.json?search_string=${this.search_text}`

            if(this.search_mode == 'module' && this.id){
                url += `&module_id=${this.id}`
            }
            if(this.search_mode == 'bucket' && this.bucket && this.bucket.id){
                url += `&bucket_id=${this.bucket.id}`
            }
            url += `&page=${this.pagination.current_page}&perPage=${this.pagination.per_page}`

            this.strings = {
                records: []
            }

            */

            this.http.get(url).then(result => {
                console.log(result)
            }).catch(error => {
                console.error(error)
            }).finally(()=>{
                this.loading = false
            })

        }
    }
})

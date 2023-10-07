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
export const useModule = defineStore("babel.module", {
    state: () => {
        return {
            id: 0,
            code: "",
            platform: "",
            buckets: []
        }
    },
    actions: {
        fetchModule(modulo) {
            if (!modulo) return;
            this.http.get(this.url.babel("modules/:id", modulo)).then(result => {
                this.id = result.id
                this.code = result.code
                this.platform = result.platform
                this.fetchBuckets()
            })
        },
        fetchBuckets() {
            this.http.get(this.url.babel("modules/:id/buckets", this.id)).then(result => {
                this.buckets = result
            })
        }
    }
})

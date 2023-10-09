/*
Lesli

Copyright (c) 2023, Lesli Technologies, S. A.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.

Lesli · Ruby on Rails SaaS Development Framework.

Made with ♥ by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  hello@lesli.tech
@website  https://www.lesli.tech
@license  GPLv3 http://www.gnu.org/licenses/gpl-3.0.en.html

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
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

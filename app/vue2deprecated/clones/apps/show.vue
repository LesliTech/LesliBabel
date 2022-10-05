<script>
/*
Copyright (c) 2020, all rights reserved.

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


// · import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~



// ·
export default {
    data() {
        return {
            instance_code: null,
            loading: false
        }
    },
    methods: {

        loadingIndicator(el, state=true) {

            if (state === true) {
                el.classList.add("fa-spin")
                return
            }

            el.classList.remove("fa-spin")
            this.$router.go()

        },

        postClone(e) {
            this.loading = true
            this.loadingIndicator(e.target)
            this.http.post(this.url.babel("clone"), {
                clone: {
                    instance_code: this.instance_code
                }
            }).then(result => {
                console.log(result)
            }).finally(() => {
                this.loadingIndicator(e.target, false)
                this.loading = false
            })
        }

    }
}
</script>
<template>
    <section class="application-component">
        <component-header title="Clone strings"></component-header>
        <div class="box">
            <div class="field">
                <label class="label">Name</label>
                <div class="control">
                    <div class="select">
                        <select v-model="instance_code">
                            <option value="lesli_cloud">Lesli</option>
                            <option value="mitwerken_cloud">Mitwerken</option>
                            <option value="deutsche_leibrenten">Deutsche leibrenten</option>
                        </select>
                    </div>
                </div>
                <span>Code: {{ instance_code }}</span>
            </div>
            <button class="button is-primary" @click="postClone" :disabled="loading">clone</button>
        </div>
    </section>
</template>

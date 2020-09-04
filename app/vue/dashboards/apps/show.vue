<script>
/*
Lesli

Copyright (c) 2020, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

Lesli - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@contact  <hello@lesli.tech>
@website  <https://lesli.tech>
@license  Propietary - all rights reserved.

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


// · import components
// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~


// · 
export default {
    data() {
        return {
            stats: {},
        }
    },
    mounted() {
        this.getStats()
    },
    methods: {

        getStats() {
            this.http.get("/babel/translation/resources/stats").then(result => {
                if (result.successful) {
                    this.stats = result.data
                }else{
                    this.alert(result.error.message,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }

    }

}
</script>
<template>
    <section class="application-component">

        <component-header :title="'Registered ' + stats.total_strings + ' labels '">
        </component-header>

        <div class="columns">
            <div class="column" v-for="locale in stats.total_strings_translations" :key="locale.code">
                <div class="card">
                    <div class="card-content has-text-centered">
                        <span :class="['is-size-2','flag-icon', 'flag-icon-'+(locale.code == 'en' ? 'gb':locale.code)]"></span>
                        <p class="is-size-5">
                            {{ locale.name }}: {{ locale.total }} translations
                        </p>
                        <small>
                            missing: {{ stats.total_strings - locale.total }} translations
                        </small>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title">
                    {{ stats.total_strings_waiting_for_help }} labels waiting for help
                </h2>
            </div>
        </div>

        <br>

    </section>
</template>

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
            main_route: '/babel/translation/resources/stats',
            stats: {},
        }
    },
    mounted() {
        this.getStats()
    },
    methods: {

        getStats() {
            this.http.get(this.main_route).then(result => {
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

        <div class="card">
            <div class="card-header">
                <h2 class="card-header-title is-size-3">{{ stats.total_strings }} total labels</h2>
            </div>
        </div>

        <br>

        <div class="columns">
            <div class="column">

                <div class="card">
                    <div class="card-content">
                        <h4 class="is-size-3">{{ stats.total_strings - stats.total_strings_es_translations }}</h4>
                        <span class="flag-icon flag-icon-es is-size-3"></span>
                        <p class="is-size-5">missing <b>es</b> translations</p>
                    </div>
                </div>

            </div>
            <div class="column">

                <div class="card">
                    <div class="card-content">
                        <h4 class="is-size-3">{{ stats.total_strings - stats.total_strings_en_translations }}</h4>
                        <span class="flag-icon flag-icon-gb is-size-3"></span>
                        <p class="is-size-5">missing <b>en</b> translations</p>
                    </div>
                </div>

            </div>
            <div class="column">

                <div class="card">
                    <div class="card-content">
                        <h4 class="is-size-3">{{ stats.total_strings - stats.total_strings_de_translations }}</h4>
                        <span class="flag-icon flag-icon-de is-size-3"></span>
                        <p class="is-size-5">missing <b>de</b> translations</p>
                    </div>
                </div>

            </div>
            <div class="column">

                <div class="card">
                    <div class="card-content">
                        <h4 class="is-size-3">{{ stats.total_strings - stats.total_strings_fr_translations }}</h4>
                        <span class="flag-icon flag-icon-fr is-size-3"></span>
                        <p class="is-size-5">missing <b>fr</b> translations</p>
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

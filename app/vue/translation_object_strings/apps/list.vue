<script>
/*
Lesli

Copyright (c) 2019, Lesli Technologies, S. A.

All the information provided by this website is protected by laws of Guatemala related 
to industrial property, intellectual property, copyright and relative international laws. 
Lesli Technologies, S. A. is the exclusive owner of all intellectual or industrial property
rights of the code, texts, trade mark, design, pictures and any other information.
Without the written permission of Lesli Technologies, S. A., any replication, modification,
transmission, publication is strictly forbidden.
For more information read the license file including with this software.

LesliCloud - Your Smart Business Assistant

Powered by https://www.lesli.tech
Building a better future, one line of code at a time.

@author   LesliTech <hello@lesli.tech>
@license  Propietary - all rights reserved.
@version  0.1.0-alpha

// · ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~     ~·~
// · 
*/


export default {
    data() {
        return {
            translation_object_string: {
                label: '',
                es: '',
                en:'',
                de:'',
                fr:'',
                cloud_babel_translation_objects_id: '1'
            },
            translation_object_strings: [],
            columns: [{
                field: 'id',
                label: 'Id'
            },{
                field: 'label',
                label: 'Entry'
            },{
                field: 'es',
                label: 'Spanish'
            },{
                field: 'en',
                label: 'English'
            },{
                field: 'de',
                label: 'German'
            },{
                field: 'fr',
                label: 'French'
            }],
        }
    },
    mounted() {
        this.getTranslationObjectStrings()
    },
    methods: {
        getTranslationObjectStrings() {
            this.http.get('/babel/translation_object_strings.json').then(result => {
                if (!result.successful) {
                    return 
                }
                this.translation_object_strings = result.data
            }).catch(error => {
                console.log(error)
            })
        },
        postTranslationObjectString(e) {
            if (e) { e.preventDefault() }
            this.http.post('/babel/translation_object_strings', {
                translation_object_string: this.translation_object_string
            }).then(result => {
                if (result.successful) {
                window.location.reload('/')
                }
            }).catch(error => {
                console.log(error)
            })
        },
    }
}
</script>
<template>
    <section class="section">
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    Add new translation file
                </h4>
            </div>
            <div class="card-content">
                <form @submit="postTranslationObjectString">
                    <div class="field is-horizontal">
                        <div class="field-body">
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" placeholder="Entry" v-model="translation_object_string.label">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" placeholder="Spanish" v-model="translation_object_string.es">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" placeholder="English" v-model="translation_object_string.en">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" placeholder="German" v-model="translation_object_string.de">
                                </p>
                            </div>
                            <div class="field">
                                <p class="control is-expanded">
                                    <input class="input" type="text" placeholder="French" v-model="translation_object_string.fr">
                                </p>
                            </div>
                            <div class="field">
                                <div class="control">
                                    <button class="button is-primary">
                                        Save
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <br />
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    All the files
                </h4>
            </div>
            <div class="card-content">
                <b-table
                    :data="translation_object_strings"
                    :columns="columns"
                    :hoverable="true">
                </b-table>
            </div>
        </div>
    </section>
</template>

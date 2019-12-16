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
            isPaginated: true,
            currentPage: 1,
            perPage: 50,
            translation_object_id: null,
            translation_id: null,
            translation_object_string: {
                label: '',
                es: '',
                en:'',
                de:'',
                fr:'',
                cloud_babel_translation_objects_id: this.$route.params.translation_object_id
            },
            translation_object_strings: [],
            columns: [{
                field: 'id',
                label: 'ID',
                centered: true
            },{
                field: 'label',
                label: 'Entry',
                searchable: true
            },{
                field: 'es',
                label: 'Spanish',
                searchable: true
            },{
                field: 'en',
                label: 'English',
                searchable: true
            },{
                field: 'de',
                label: 'German',
                searchable: true
            },{
                field: 'fr',
                label: 'French',searchable: true
            }],
        }
    },
    mounted() {
        this.translation_object_id = this.$route.params.translation_object_id
        this.translation_id = this.$route.params.translation_id
        this.getTranslationObjectStrings()
    },
    methods: {
        getTranslationObjectStrings() {
            this.http.get(`/babel/translations/${this.translation_id}/translation_objects/${this.translation_object_id}/translation_object_strings.json`).then(result => {
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
            this.http.post('/babel/translations/:translation_id/translation_objects/:translation_object_id/translation_object_strings', {
                translation_object_string: this.translation_object_string
            }).then(result => {
                if (result.successful) {
                    this.alert("Translation object string created", 'success' )
                    this.getTranslationObjectStrings()
                }
            }).catch(error => {
                console.log(error)
            })
        },
        clickTranslationObjectString(translation_object_string){
            this.$router.push(`/translations/${this.translation_id}/translation_objects/${this.translation_object_id}/translation_object_strings/${translation_object_string.id}/edit`)
        }
    }
}
</script>
<template>
    <section class="section">
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    Add new translation object string at file
                </h4>
                <router-link :to="`/translations/${this.translation_id}/translation_objects`" class="card-header-icon">
                    <i class="fas fa-undo"></i>
                    Return
                </router-link>
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
                    :paginated="isPaginated"
                    :per-page="perPage"
                    :current-page.sync="currentPage"
                    :data="translation_object_strings"
                    :columns="columns"
                    :hoverable="true"
                    @click="clickTranslationObjectString">
                </b-table>
            </div>
        </div>
    </section>
</template>

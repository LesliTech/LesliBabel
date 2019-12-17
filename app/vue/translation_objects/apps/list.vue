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
            modal:{
                active:false
            },
            isPaginated: true,
            currentPage: 1,
            perPage: 15,
            filters: {
                method: '',
                object_type: '',
                section:''
            },
            translation_id: null,
            translation_object: {
                method: '',
                object_type: '',
                section:'',
                cloud_babel_translations_id: this.$route.params.translation_id
            },
            translation_objects: [],
        }
    },
    mounted() {
        this.translation_id = this.$route.params.translation_id
        this.getTranslationObjects()
    },
    computed: {
        filteredTranslationObjects: function() {
            var filtered_translation_objects = this.translation_objects.filter((translation_object) => {
                var filtered = translation_object.method.includes(this.filters.method) &&
                translation_object.object_type.includes(this.filters.object_type) &&
                translation_object.section.includes(this.filters.section)
                return filtered
            })
            return filtered_translation_objects
        }
    },
    methods: {
        getTranslationObjects() {
            this.http.get(`/babel/translations/${this.translation_id}/translation_objects.json`).then(result => {
                if (!result.successful) {
                    return 
                }
                this.translation_objects = result.data
            }).catch(error => {
                console.log(error)
            })
        },
        postTranslationObject(e) {
            if (e) { e.preventDefault() }
            this.http.post('/babel/translations/:translation_id/translation_objects', {
                translation_object: this.translation_object
            }).then(result => {
                if (result.successful) {
                    this.alert("Translation object created", 'success' )
                    this.getTranslationObjects()
                }
            }).catch(error => {
                console.log(error)
            })
        },
        clickTranslationObject(translation_object_id){
            this.url.go(`/babel/translations/${this.translation_id}/translation_objects/${translation_object_id}/translation_object_strings`)
        },
        DeleteTranslationObject(translation_object_id){
            this.http.delete(`/babel/translations/${this.translation_id}/translation_objects/${translation_object_id}`).then(result => {
                if(result.successful){
                    this.alert(`Translation object ${translation_object_id} deleted `, 'danger' )
                    this.getTranslationObjects()
                } else {
                    this.alert(result.error,'danger')
                }
            }).catch(error => {
                console.log(error)
            })
        }
    }
}
</script>
<template>
    <section class="section">
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    Add new translation object at file
                </h4>
            </div>
            <div class="card-content">
                <form @submit="postTranslationObject">
                    <div class="columns is-centered"> 
                        <div class="column is-3">
                            <p class="control is-expanded">
                                <input class="input" type="text" placeholder="Method" v-model="translation_object.method">
                            </p>
                        </div>
                        <div class="column is-3">
                            <p class="control is-expanded">
                                <input class="input" type="text" placeholder="Type" v-model="translation_object.object_type">
                            </p>
                        </div>
                        <div class="column is-3">
                            <p class="control is-expanded">
                                <input class="input" type="text" placeholder="Section" v-model="translation_object.section">
                            </p>
                        </div>
                        <div class="column is-1">
                            <div class="control">
                                <button class="button is-primary">
                                    Save
                                </button>
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
                <div class="columns is-centered"> 
                    <div class="column is-3">
                        <p class="control is-expanded">
                            <input v-model=filters.method class="input" type="text" placeholder="Search by meethod">
                        </p>
                    </div>
                    <div class="column is-3">
                        <p class="control is-expanded">
                            <input v-model=filters.object_type class="input" type="text" placeholder="Search by type">
                        </p>
                    </div>
                    <div class="column is-3">
                        <p class="control is-expanded">
                            <input v-model=filters.section class="input" type="text" placeholder="Search by section">
                        </p>
                    </div>
                </div>
                <b-table
                    :paginated="isPaginated"
                    :per-page="perPage"
                    :current-page.sync="currentPage"
                    :data=filteredTranslationObjects
                    >
                    <template v-slot="props">
                        <b-table-column field="id" label="ID" width="40"  numeric>
                            {{ props.row.id }}
                        </b-table-column>
                        <b-table-column field="method" label="Method">
                            {{ props.row.method }}
                        </b-table-column>
                        <b-table-column field="object_type" label="Type">
                            {{ props.row.object_type }}
                        </b-table-column>
                        <b-table-column field="section" label="Section">
                            {{ props.row.section }}
                        </b-table-column>
                        <b-table-column label="Watch" >
                            <a @click="clickTranslationObject(props.row.id)"
                            >
                            <b-icon icon="eye"/>
                            </a>
                        </b-table-column>
                        <b-table-column label="Delete" >
                            <a @click="DeleteTranslationObject(props.row.id)"
                            >
                            <b-icon icon="trash"/>
                            </a>
                        </b-table-column>
                    </template>
                </b-table>
                
            </div>
        </div>
    </section>
</template>

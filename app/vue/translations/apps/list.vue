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
            perPage: 15,
            filters: {
                id: '',
                module_name: '',
                class_name: ''
            },
            translations: [],
            translation: {
                id: '',
                module_name: '',
                class_name: ''
            },
            modules: [
                { 'id': 1, 'module_name': 'Lesli'},
                { 'id': 2, 'module_name': 'Help'},
                { 'id': 3, 'module_name': 'Lock'},
                { 'id': 4, 'module_name': 'Babel'},
                { 'id': 5, 'module_name': 'Driver'},
                { 'id': 6, 'module_name': 'Bell'},
                { 'id': 7, 'module_name': 'Team'}
            ]
        }
    },
    mounted() {
        this.getTranslations()
    },
    computed: {
        filteredTranslations: function(){
            var filtered_translations = this.translations.filter((translation) => {
                var filtered = translation.module_name.includes(this.filters.module_name) && 
                translation.class_name.includes(this.filters.class_name)
                return filtered
            })
            return filtered_translations
        }
        },
    methods: {
        getTranslations() {
            this.http.get('/babel/translations.json').then(result => {
                if (!result.successful) {
                    return 
                }
                this.translations = result.data
            }).catch(error => {
                console.log(error)
            })
        },
        postTranslation(e) {
            if (e) { e.preventDefault() }
                this.http.post('/babel/translations', {
                translation: this.translation
            }).then(result => {
                if (result.successful) {
                    this.alert("Translation created", 'success' )
                    this.getTranslations()
                }
            }).catch(error => {
                console.log(error)
            })
        },
        clickTranslation(translation_id){
            this.url.go(`/babel/translations/${translation_id}/translation_objects`)
        },
        DeleteTranslation(translation_id){
            this.http.delete(`/babel/translations/${translation_id}/`).then(result => {
                if(result.successful){
                    this.getTranslations()
                    this.alert(`Translation ${translation_id} deleted `, 'danger' )
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
    <section class="application-component">
        <div class="card">
            <div class="card-header">
                <h4 class="card-header-title">
                    Add new translation at file
                </h4>
            </div>
            <div class="card-content">
                <form @submit="postTranslation">
                    <div class="columns is-centered"> 
                        <div class="column is-1 ">
                                <b-select  v-model="translation.module_name">
                                    <option
                                    v-for="option in modules"
                                    :value="option.module_name"
                                    :key="option.id">
                                    {{option.module_name}}
                                    </option>
                                </b-select>
                            </div>
                        <div class="column is-4">
                                <p class="control is-expanded">
                                    <input class="input" type="text" placeholder="Class name" v-model="translation.class_name">
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
                    <div class="column is-4">
                            <p class="control is-expanded">
                                <input v-model=filters.module_name class="input" type="text" placeholder="Search by module name">
                            </p>
                    </div>
                    <div class="column is-4">
                            <p class="control is-expanded">
                                <input v-model=filters.class_name class="input" type="text" placeholder="Search by class name">
                            </p>
                    </div>
                </div>
               <b-table
                    :paginated="isPaginated"
                    :per-page="perPage"
                    :current-page.sync="currentPage"
                    :data=filteredTranslations>
                    <template v-slot="props">
                        <b-table-column field="id" label="ID" width="40"  numeric>
                            {{ props.row.id }}
                        </b-table-column>
                        <b-table-column field="module_name" label="Module" >
                            {{ props.row.module_name }}
                        </b-table-column>
                        <b-table-column field="class_name" label="Class name"  >
                            {{ props.row.class_name }}
                        </b-table-column>
                        <b-table-column label="Watch" >
                            <a @click="clickTranslation(props.row.id)"
                            >
                            <b-icon icon="eye"/>
                            </a>
                        </b-table-column>
                        <b-table-column label="Delete" >
                            <a @click="DeleteTranslation(props.row.id)"
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

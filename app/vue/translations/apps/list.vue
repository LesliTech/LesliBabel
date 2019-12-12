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
            isPaginationSimple: false,
            paginationPosition: 'bottom',
            currentPage: 1,
            perPage: 5,
            modules: [
                { 'id': 1, 'module_name': 'Lesli'},
                { 'id': 2, 'module_name': 'Help'},
                { 'id': 3, 'module_name': 'Lock'},
                { 'id': 4, 'module_name': 'Babel'},
                { 'id': 5, 'module_name': 'Driver'},
                { 'id': 6, 'module_name': 'Bell'},
                { 'id': 7, 'module_name': 'Team'}
            ],
            translation: {
                module_name: '',
                class_name: ''
            },
            translations: [],
            columns: [{
                field: 'id',
                label: 'ID',
                centered: true
            },{
                field: 'module_name',
                label:'Module',
                searchable: true,
            }, {
                field: 'class_name',
                label: 'Class name',
                searchable: true,
            }]
        }
    },
    mounted() {
        this.getTranslations()
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
                window.location.reload('/babel/translations')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        clickTranslation(translation){
            this.$router.push(`/translation_objects/`)
            window.location.reload('/babel/translation_objects')
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
                <b-field grouped group-multiline>
                    <b-select v-model="perPage" :disabled="!isPaginated">
                        <option value="5">5 per page</option>
                        <option value="10">10 per page</option>
                        <option value="15">15 per page</option>
                        <option value="20">20 per page</option>
                    </b-select>
                    <div class="control is-flex">
                        <b-switch v-model="isPaginated">Paginated</b-switch>
                    </div>
                    <div class="control is-flex">
                        <b-switch v-model="isPaginationSimple" :disabled="!isPaginated">Simple pagination</b-switch>
                    </div>
                </b-field>
                <b-table
                    :paginated="isPaginated"
                    :per-page="perPage"
                    :current-page.sync="currentPage"
                    :pagination-simple="isPaginationSimple"
                    :pagination-position="paginationPosition"
                    :data="translations"
                    :columns="columns"
                    :hoverable="true"
                    @click="clickTranslation">
                </b-table>
            </div>
        </div>
    </section>
</template>

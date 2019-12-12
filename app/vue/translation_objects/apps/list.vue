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
            translation_object: {
                method: '',
                object_type: '',
                section:'',
                cloud_babel_translations_id: '2'
            },
            translation_objects: [],
            columns: [{
                field: 'id',
                label: 'ID',
                centered: true
            },{
                field: 'method',
                label: 'Method',
                searchable: true
            },{
                field: 'object_type',
                label: 'Type',
                searchable: true
            },{
                field: 'section',
                label: 'Section',
                searchable: true
            }],
        }
    },
    mounted() {
        this.getTranslationObjects()
    },
    methods: {
        getTranslationObjects() {
            this.http.get('/babel/translation_objects.json').then(result => {
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
            this.http.post('/babel/translation_objects', {
                translation_object: this.translation_object
            }).then(result => {
                if (result.successful) {
                window.location.reload('/translation_objects')
                }
            }).catch(error => {
                console.log(error)
            })
        },
        clickTranslationObject(translation_object){
            this.$router.push(`/translation_object_strings/`)
            window.location.reload('/babel/translation_objects')
        }
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
                    :data="translation_objects"
                    :columns="columns"
                    :hoverable="true"
                    @click="clickTranslationObject">
                </b-table>
            </div>
        </div>
    </section>
</template>

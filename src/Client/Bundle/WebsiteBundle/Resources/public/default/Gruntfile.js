'use strict';

module.exports = function(grunt) {
    // load all Grunt tasks
    require('load-grunt-tasks')(grunt, {pattern: ['grunt-contrib-*', 'grunt-*']});

    // init grunt config
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        config: grunt.file.readJSON('grunt/config.json'),
        uglifyFiles: grunt.file.readJSON('grunt/js-files.json'),

        // messages
        notify: {
            watch: {
                options: {
                    title: '<%= pkg.name %> - watch',
                    message: 'Starting up! Livereload is on Port "<%= config.livereloadPort %>"'
                }
            },
            compass: {
                options: {
                    title: '<%= pkg.name %> - compass',
                    message: 'CSS Compiled!'
                }
            },
            uglify: {
                options: {
                    title: '<%= pkg.name %> - uglify',
                    message: 'JavaScript Compiled!'
                }
            }
        },

        // Compass Task for Compiling scss
        compass: {
            dist: {
                options: {
                    sassDir: '<%= config.path.scss %>',
                    cssDir: '<%= config.path.css %>',
                    environment: 'production'
                }
            },
            dev: {
                options: {
                    sassDir: '<%= config.path.scss %>',
                    cssDir: '<%= config.path.css %>',
                    environment: 'development'
                }
            }
        },

        // Uglify to Compile scripts
        uglify: {
            options: {
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
            },
            dev: {
                options: {
                    mangle: false,
                    compress: false,
                    preserveComments: 'all',
                    beautify: true,
                    sourceMap: true,
                    sourceMapName: '<%= config.path.js %>/sourcemap.map'
                },
                files:  {
                    '<%= config.path.js %>/<%= config.js.outputFile %>': ["<%= uglifyFiles %>"]
                }
            }
        },

        // Define the watch tasks
        watch: {
            css: {
                files: '<%= config.path.scss %>/**/*.scss',
                tasks: ['compass:dev', 'notify:compass'],
                options: {
                    livereload: "<%= config.livereloadPort %>"
                }
            },
            js: {
                files: '<%= config.path.scripts %>/**/*.js',
                tasks: ['uglify:dev', 'notify:uglify'],
                options: {
                    livereload: "<%= config.livereloadPort %>"
                }
            }
        }
    });

    grunt.registerTask('dev', ['watch']);
};
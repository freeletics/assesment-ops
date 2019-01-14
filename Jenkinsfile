node {
    // Checking out a branch (This can be done slightly better with GitHub plugin)
      stage('Checkout SCM') {
        git (
        url: 'https://github.com/saleee011/test-ops.git',
        branch: 'ci-cd'
        )
      }
    // Building the image and running tests before pushing the container
    stage('Build the container') {
        docker.build("saleee011/ruby-alpine")
    }
    stage('Test the container') {
    docker.image('postgres').withRun('--name postgres -e "POSTGRES_PASSWORD=mysecretpassword"') { c ->

        docker.image('saleee011/ruby-alpine').inside('--link postgres -e "DATABASE_URL=postgres" -e "DATABASE_USER=postgres" -e "DATABASE_PASSWORD=mysecretpassword" -e "SECRET_KEY_BASE=928d4c0c3ee7fba47bf71a6da72c1763a9331850267d9d4a8ee2c0df3655776b647d09f005b94bbc90069c577f56b9cad9749baa64c0fc2472b5f57881e5480e"') {
            sh 'ruby bin/setup'
            sh 'rails test test/test_helper.rb'
            }
        }
    }
    // Using a docker registry and credentials id to access it 
    stage('Push the container') {
        withDockerRegistry(url: '',  credentialsId: 'hub') {
            sh "docker push saleee011/ruby-alpine"
        }
    }
}
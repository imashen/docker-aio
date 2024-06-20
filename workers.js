addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const url = 'https://get.docker.com'

  const response = await fetch(url)
  const scriptContent = await response.text()

  return new Response(scriptContent, {
      headers: {
          'Content-Type': 'text/plain',
      },
  })
}

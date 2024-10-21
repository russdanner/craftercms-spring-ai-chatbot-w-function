<#import "/templates/system/common/crafter.ftl" as crafter />

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>${contentModel.title_t}</title>
    <style>
        /* Existing styles maintained below... */
        html, body {
            color: #333;
            height: 100%;
            background: linear-gradient(to bottom, silver, black);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
        }

        .main {
            display: flex;
            flex-direction: column;
            max-width: 800px;
            height: 80vh;
            padding: 40px;
            border-radius: 20px;
            margin: 5% auto;
            background: white;
            box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
        }

        .chat-box {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            border: 1px solid #ccc;
            margin-bottom: 20px;
            border-radius: 10px;
            background-color: rgba(255,255,255,0.5);
        }

        .chat-box p {
            margin: 5px 0;
        }

        .chat-box p:nth-child(odd) {
            align-self: flex-start;
            background-color: #f9f9f9;
            border-radius: 5px;
        }

        .chat-box p:nth-child(even) {
            align-self: flex-end;
            background-color: #e6e6e6;
            border-radius: 5px;
        }

        .chat-input {
            display: flex;
        }

        .chat-input input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

        .chat-input button {
            background-color: #333;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            margin-left: 10px;
            cursor: pointer;
        }

        h1 {
            color: white;
            text-align: center;
        }

        /* Spinner styles added */
        #spinner {
            width: 3rem;
            height: 3rem;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            display: none; /* Hide the spinner initially */
        }

    </style>
    <@crafter.head/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body>
    <@crafter.body_top/>
    <main>
        <@crafter.h1 $field="title_t">${contentModel.title_t}</@crafter.h1>

        <div class="chat-box"></div>
        <form class="chat-input">
            <input type="text" id="prompt" name="prompt" placeholder="Type your message...">
            
            <button id="startButton">Start Voice Input</button>
            
            <button type="submit">Send</button>

        </form>

     <!-- Spinner component -->
    <div class="spinner-border text-primary" role="status" id="spinner">
        <span class="sr-only">Loading...</span>
    </div>

    </main>
    <@crafter.body_bottom/>

    <script>
const startButton = document.getElementById('startButton');
const outputDiv = document.getElementById('prompt');

const recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition || window.mozSpeechRecognition || window.msSpeechRecognition)();
recognition.lang = 'en-US';

recognition.onstart = () => {
    startButton.textContent = 'Listening...';
};

recognition.onresult = (event) => {
    const transcript = event.results[0][0].transcript;
    outputDiv.value = transcript;
};

recognition.onend = () => {
    startButton.textContent = 'Start Voice Input';
};

startButton.addEventListener('click', () => {
    recognition.start();
});

        $('.chat-input').on('submit', function(e) {
            e.preventDefault(); 
            var prompt = $(this).find('input').val();

            // show spinner
            $('#spinner').show();

            $.get("/api/agent/request.json", { prompt: prompt })
            .done(function(data) {
                var pattern = /\n/gi;
                data = (""+data).replace(pattern, "<br/>");
                $('.chat-box').append('<p>You: ' + prompt + '</p>');
                $('.chat-box').append('<p>Bot: ' + data + '</p>'); 

                // hide spinner
                $('#spinner').hide();
            });
        });
    </script>

</body>
</html>

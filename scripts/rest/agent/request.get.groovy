@Grab(group='org.springframework.ai', module='spring-ai-core', version='1.0.0-SNAPSHOT', initClass=false)
@Grab(group='org.springframework.ai', module='spring-ai-openai', version='1.0.0-SNAPSHOT', initClass=false)

import org.springframework.ai.*
import org.springframework.ai.chat.prompt.Prompt
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.model.function.FunctionCallbackWrapper
import org.springframework.ai.openai.OpenAiChatOptions
import org.springframework.ai.openai.OpenAiChatModel
import org.springframework.ai.openai.api.OpenAiApi
import org.springframework.ai.openai.api.OpenAiApi.ChatModel;
import org.springframework.ai.openai.api.OpenAiApi.ChatCompletionRequest
import org.springframework.ai.openai.api.OpenAiApi.ChatCompletionRequest.ResponseFormat

import org.springframework.web.client.RestClient
import org.springframework.web.client.RestClient.Builder
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.http.HttpHeaders
import org.springframework.stereotype.Component

import java.util.Map
import java.util.List
import java.util.function.Function

@Component
public class CheckAvailabilityTool implements Function<CheckAvailabilityTool.Request, CheckAvailabilityTool.Response> {

    public CheckAvailabilityTool() {}
    public CheckAvailabilityTool(boolean available) {}
    
    public record Request(String date) {}
    public record Response(CheckAvailabilityTool tool, java.lang.Boolean available) {}

    @Override
    public Response apply(Request request) {
        
        return new Response(false)
    }
}

String openAIKey = System.getenv("crafter_chatgpt")
String userPrompt = params.prompt

if(!userPrompt) {
    response.setStatus(500)
    return "prompt is a required parameter"
}

RestClient.Builder restClientBuilder = RestClient.builder()
WebClient.Builder webClientBuilder = WebClient.builder()

restClientBuilder.defaultHeaders {
    it.set(HttpHeaders.ACCEPT_ENCODING, "gzip, deflate")
}
    
OpenAiApi openAiApi = new OpenAiApi("https://api.openai.com", openAIKey, restClientBuilder, webClientBuilder)

FunctionCallbackWrapper checkAvailabilityFuncCallWrapper = FunctionCallbackWrapper.builder(new CheckAvailabilityTool())
    	.withName("CheckAvailability")
    	.withDescription("Returns true if rooms are available")
        .withResponseConverter((response) -> "" + response.available())
        .build()

OpenAiChatOptions openAiChatOptions = OpenAiChatOptions.builder()
    .withModel(ChatModel.GPT_4_O_MINI.getName())
    .withFunctionCallbacks(List.of( checkAvailabilityFuncCallWrapper ))
    .build();

OpenAiChatModel chatModel = new OpenAiChatModel(openAiApi)

def modelResponse = chatModel.call(new Prompt(new UserMessage(userPrompt), openAiChatOptions))

return modelResponse.results.output.content
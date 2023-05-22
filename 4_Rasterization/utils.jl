import GLFW  # we focus exclusively on the GLFW approach
using ModernGL

#############################################################################
# simple callback function that closes the window when the Esc key is pressed
#############################################################################
function key_callback(window::GLFW.Window, key::GLFW.Key, scancode::Int32, action::GLFW.Action, mods::Int32)
    if (key == GLFW.KEY_ESCAPE && action == GLFW.PRESS)
        GLFW.SetWindowShouldClose(window, true)
    end
end

####################################################
# this method sets up a window for OpenGL rendering.
####################################################
function initWindow(;windowSize::NTuple{2,Int64}=(800,600), title::String="window 1", callbackFunc=key_callback)

    # The GLFW package calls GLFW.Init() automatically when loaded, so we
    # don't need to call it explicitly.

    # Specify minimum versions
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)  # minimum OpenGL v. 3
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 2)  # minimum OpenGL v. 3.2
    GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
    GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE)

    # Create the window
    GLFW.WindowHint(GLFW.RESIZABLE, GL_FALSE)
    window = GLFW.CreateWindow(windowSize[1], windowSize[2], title)  # windowed
    GLFW.MakeContextCurrent(window)

    # This is a touch added from
    #   http://www.opengl-tutorial.org/beginners-tutorials/tutorial-1-opening-a-window/:
    # Retain keypress events until the next call to GLFW.GetKey, even if
    # the key has been released in the meantime
    GLFW.SetInputMode(window, GLFW.STICKY_KEYS, GL_TRUE)

    GLFW.SetKeyCallback(window,callbackFunc)

    return window
end

########################################################################################
# take source code for the vertex and fragment shader and compile&link the shaderprogram
########################################################################################
function compileShaderProgram(vertex_source::String, fragment_source::String)
   # Compile the vertex shader
    vertex_shader = glCreateShader(GL_VERTEX_SHADER)
    vertex_shader_Ptr = Ptr{UInt8}[pointer(vertex_source)]
    lenVert = Ref{GLint}(length(vertex_source))
    glShaderSource(vertex_shader,1, vertex_shader_Ptr, lenVert)
    glCompileShader(vertex_shader)

    # Check for compilation errors
    status = Ref(GLint(0))
    glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, status)
    if status[] != GL_TRUE
        buffer = zeros(UInt8, 512)
        glGetShaderInfoLog(vertex_shader, 512, C_NULL, buffer)
        error(unsafe_string(pointer(buffer)))
    end

    # Compile the fragment shader
    fragment_shader = glCreateShader(GL_FRAGMENT_SHADER)
    fragment_shader_Ptr = Ptr{UInt8}[pointer(fragment_source)]
    lenFrag = Ref{GLint}(length(fragment_source))
    glShaderSource(fragment_shader, 1, fragment_shader_Ptr, lenFrag)
    glCompileShader(fragment_shader)

    #Check for compilation errors
    statusFrag=Ref(GLint(0))
    glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, statusFrag)
    if statusFrag[] != GL_TRUE
        buffer = zeros(UInt8, 512)
        glGetShaderInfoLog(fragment_shader, 512, C_NULL, buffer)
        error(unsafe_string(pointer(buffer)))
    end

    shader_program = glCreateProgram();
    glAttachShader(shader_program, vertex_shader);
    glAttachShader(shader_program, fragment_shader);

    glLinkProgram(shader_program)
    glUseProgram(shader_program)

    return shader_program
end

####################################################################################
# load an object from a file. Optionally vertices can be scaled by a constant factor
####################################################################################
function load_obj(filename::String, scale=0.7)
    vertices = Array{Float32}(undef,0)
    indices = Array{UInt32}(undef,0)

    # read .obj file line for line
    for line in readlines(filename)
        if line[1:2] == "v "
            # read the x, y and z position of each vertex
            strvals = split(line,' ')[2:4]
            push!(vertices,map(x->parse(Float32,x),strvals)...)
            vertices[end] *= -1
        elseif line[1:2] == "f "
            # read the triple of references
            strvals = split(line,[' '])[2:4]
            push!(indices,map(x->parse(UInt16,x)-1,strvals)...)
        end
    end

    # scale down object in object coordinate sytem
    map!(x->scale*x,vertices,vertices)
    return vertices, indices
end

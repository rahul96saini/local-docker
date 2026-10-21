FROM ubuntu:24.04

# Create users
RUN useradd -m Mohan && \
    useradd -m Uma && \
    useradd -m Shikha && \
    useradd -m Mayank

# Create directory structure
RUN mkdir -p /Data/Ninjas/Mohan \
             /Data/Ninjas/Uma \
             /Data/Ninjas/Shikha \
             /Data/Ninjas/Mayank

# Set ownership
RUN chown Mohan:Mohan /Data/Ninjas/Mohan && \
    chown Uma:Uma /Data/Ninjas/Uma && \
    chown Shikha:Shikha /Data/Ninjas/Shikha && \
    chown Mayank:Mayank /Data/Ninjas/Mayank

# Set permissions
RUN chmod 755 /Data/Ninjas/Mohan && \
    chmod 755 /Data/Ninjas/Uma && \
    chmod 755 /Data/Ninjas/Shikha && \
    chmod 755 /Data/Ninjas/Mayank

# Run the container as Mohan
USER Mohan

CMD ["bash"]